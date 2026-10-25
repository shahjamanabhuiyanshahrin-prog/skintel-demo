import json
import os
import time
import urllib.parse
import urllib.request

import cv2
import numpy as np
from flask import Flask, request, jsonify
from flask_cors import CORS
from google import genai
from google.genai import types

app = Flask(__name__)
CORS(app)

# The key is read from the GEMINI_API_KEY environment variable. Never put it in code.
MODEL = os.environ.get("GEMINI_MODEL", "gemini-3.8-flash")
SKIN_TYPES = ["Dry", "Oily", "Combination", "Normal"]

face_finder = cv2.CascadeClassifier(
    cv2.data.haarcascades + "haarcascade_frontalface_default.xml"
)

PROMPT = (
    "You are a skincare assistant. Look only at the visible facial skin in this photo "
    "and estimate the skin type from visible cues: shine on the forehead, nose and "
    "cheeks, visible dryness or flaking, pore size and redness. "
    "Choose exactly one of: Dry, Oily, Combination, Normal. "
    "Lighting, makeup and filters can mislead you, so set confidence to low when the "
    "photo is not clear. If you cannot judge the skin, use skinType Unknown. "
    "Do not describe or guess the person's identity, age, gender or ethnicity. "
    'Reply with JSON only: {"skinType": "...", "confidence": "low|medium|high", '
    '"notes": "one or two short sentences about the visible cues"}.'
)


def read_image(file):
    data = np.frombuffer(file.read(), np.uint8)
    img = cv2.imdecode(data, cv2.IMREAD_COLOR)
    if img is None:
        return None
    h, w = img.shape[:2]
    scale = 640 / max(h, w)
    if scale < 1:
        img = cv2.resize(img, (int(w * scale), int(h * scale)))
    return img


def find_face(gray):
    """Returns (x, y, w, h) of the biggest face, or None."""
    faces = face_finder.detectMultiScale(
        gray, scaleFactor=1.1, minNeighbors=5, minSize=(80, 80)
    )
    if len(faces) == 0:
        return None
    x, y, w, h = max(faces, key=lambda f: f[2] * f[3])
    return int(x), int(y), int(w), int(h)


def check_light(face_gray):
    brightness = float(face_gray.mean())
    left = float(face_gray[:, :100].mean())
    right = float(face_gray[:, 100:].mean())
    uneven = abs(left - right) / max(brightness, 1.0)
    print(f"brightness={brightness:.0f}  left-right difference={uneven:.2f}")

    if brightness < 60:
        return "Too dark. Please move to a brighter place, like near a window."
    if brightness > 215:
        return "Too bright. Please move away from strong light or flash."
    if uneven > 0.35:
        return "Light is uneven. Please face the light so both sides of your face are lit."
    return ""


def face_crop_jpeg(img, box):
    """Cuts out the face with a small margin and returns JPEG bytes.
    Only the face is sent for analysis, not the room behind it."""
    x, y, w, h = box
    m = int(0.2 * max(w, h))
    y1, y2 = max(y - m, 0), min(y + h + m, img.shape[0])
    x1, x2 = max(x - m, 0), min(x + w + m, img.shape[1])
    ok, buf = cv2.imencode(".jpg", img[y1:y2, x1:x2], [cv2.IMWRITE_JPEG_QUALITY, 90])
    return buf.tobytes() if ok else None


def analyze_with_gemini(jpeg_bytes):
    """Asks Gemini for the skin type. Returns a dict, or raises an error."""
    client = genai.Client(http_options=types.HttpOptions(timeout=25_000))
    response = client.models.generate_content(
        model=MODEL,
        contents=[
            types.Part.from_bytes(data=jpeg_bytes, mime_type="image/jpeg"),
            PROMPT,
        ],
        config=types.GenerateContentConfig(response_mime_type="application/json"),
    )
    data = json.loads(response.text)
    if isinstance(data, list) and data:
        data = data[0]
    if not isinstance(data, dict):
        raise ValueError("unexpected reply")
    return data



# ---------------------------------------------------------------------------
# Products with prices (Google Shopping through SerpAPI)
# The key is read from the SERPAPI_API_KEY environment variable.
# ---------------------------------------------------------------------------
SKIN_QUERIES = {
    "Dry": "moisturizer for dry skin",
    "Oily": "oil control moisturizer for oily skin",
    "Combination": "moisturizer for combination skin",
    "Normal": "daily moisturizer for normal skin",
}
CACHE_SECONDS = 24 * 60 * 60  # keep results for a day to save the free searches
_product_cache = {}  # query -> (time, items)


def fetch_shopping(query):
    """Calls SerpAPI Google Shopping and returns the parsed JSON."""
    params = urllib.parse.urlencode({
        "engine": "google_shopping",
        "q": query,
        "gl": os.environ.get("SERPAPI_GL", "us"),
        "hl": "en",
        "api_key": os.environ["SERPAPI_API_KEY"],
    })
    with urllib.request.urlopen("https://serpapi.com/search.json?" + params, timeout=20) as r:
        return json.loads(r.read().decode("utf-8"))


def shopping_items(query):
    now = time.time()
    hit = _product_cache.get(query)
    if hit and now - hit[0] < CACHE_SECONDS:
        return hit[1]

    data = fetch_shopping(query)
    items = []
    for r in data.get("shopping_results", []):
        price = r.get("extracted_price")
        if price is None:
            continue
        items.append({
            "name": str(r.get("title", "")).strip(),
            "store": str(r.get("source", "")).strip(),
            "price": float(price),
            "price_text": str(r.get("price", "")).strip(),
            "image": str(r.get("thumbnail", "")).strip(),
            "link": str(r.get("product_link") or r.get("link") or "").strip(),
        })
    _product_cache[query] = (now, items)
    return items


@app.route("/products", methods=["GET"])
def products():
    if not os.environ.get("SERPAPI_API_KEY"):
        return jsonify({"error": "price search is not set up"}), 503

    skin = request.args.get("skin_type", "").strip().capitalize()
    category = request.args.get("category", "").strip()
    brand = request.args.get("q", "").strip()
    sort = request.args.get("sort", "asc").strip().lower()

    base = category or SKIN_QUERIES.get(skin, "skin care moisturizer")
    query = f"{brand} {base}".strip()

    try:
        items = shopping_items(query)
    except Exception as e:
        print("shopping error:", type(e).__name__, str(e)[:200])
        return jsonify({"error": "price search unavailable"}), 503

    items = sorted(items, key=lambda p: p["price"], reverse=(sort == "desc"))
    return jsonify({"products": items[:30]})


@app.route("/scan", methods=["POST"])
def scan():
    image = request.files.get("image")
    if image is None:
        return jsonify({"error": "no image"}), 400

    img = read_image(image)
    if img is None:
        return jsonify({"error": "bad image"}), 400

    # 1) Local checks first: is there a face, and is the light good?
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    box = find_face(gray)
    if box is None:
        return jsonify({
            "light_ok": "false",
            "message": "We could not see your face. Look straight at the camera and keep your whole face in the frame.",
        })

    x, y, w, h = box
    face_gray = cv2.resize(gray[y:y + h, x:x + w], (200, 200))
    problem = check_light(face_gray)
    if problem:
        return jsonify({"light_ok": "false", "message": problem})

    # 2) Only a good face photo is sent to Gemini.
    jpeg = face_crop_jpeg(img, box)
    if jpeg is None:
        return jsonify({"error": "bad image"}), 400

    try:
        result = analyze_with_gemini(jpeg)
    except Exception as e:
        print("gemini error:", type(e).__name__)
        return jsonify({"error": "analysis service unavailable"}), 503

    if isinstance(result, list) and result:
        result = result[0]
    if not isinstance(result, dict):
        return jsonify({"error": "analysis service unavailable"}), 503

    skin = str(result.get("skinType", "")).strip().capitalize()
    confidence = str(result.get("confidence", "low")).strip().lower()
    notes = str(result.get("notes", "")).strip()
    print(f"gemini: skin={skin} confidence={confidence}")

    if skin not in SKIN_TYPES:
        return jsonify({
            "light_ok": "false",
            "message": "We could not judge your skin from this photo. Try again in soft, even light.",
        })

    if confidence not in ("low", "medium", "high"):
        confidence = "low"
    notes = f"{notes} Confidence: {confidence}.".strip()

    return jsonify({
        "light_ok": "true",
        "skin_type": skin,
        "demo": "false",
        "notes": notes,
        "confidence": confidence,
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)