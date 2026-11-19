import json
import os
import time
import urllib.parse
import urllib.request

import cv2
import numpy as np
from flask import Flask, Response, request, jsonify
from flask_cors import CORS
from google import genai
from google.genai import types

import catalog

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
EXTRA_QUERIES = {
    k: [v, f"face wash cleanser for {k.lower()} skin", f"sunscreen for {k.lower()} skin"]
    for k, v in SKIN_QUERIES.items()
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
    with urllib.request.urlopen("https://serpapi.com/search.json?" + params, timeout=30) as r:
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

    # Skin-type browsing: mix a few product kinds so the list is longer.
    # A brand search or a chosen category uses a single search (saves quota).
    if category:
        queries = [f"{brand} {category}".strip()]
    elif brand:
        queries = [f"{brand} {SKIN_QUERIES.get(skin, 'skin care moisturizer')}".strip()]
    else:
        queries = EXTRA_QUERIES.get(skin) or [SKIN_QUERIES.get(skin, "skin care moisturizer")]

    items, seen = [], set()
    try:
        for q in queries:
            for p in shopping_items(q):
                key = p["link"] or p["name"]
                if key in seen:
                    continue
                seen.add(key)
                items.append(p)
    except Exception as e:
        print("shopping error:", type(e).__name__, str(e)[:200])
        if not items:
            return jsonify({"error": "price search unavailable"}), 503

    items = sorted(items, key=lambda p: p["price"], reverse=(sort == "desc"))
    return jsonify({"products": items[:90]})


# ---------------------------------------------------------------------------
# Dermatologists near you (OpenStreetMap / Overpass, free, no key).
# OpenStreetMap data is community-made, so some places have no phone number.
# ---------------------------------------------------------------------------
OVERPASS_URLS = [
    "https://overpass-api.de/api/interpreter",
    "https://overpass.kumi.systems/api/interpreter",
]
_derm_cache = {}  # rounded location -> (time, doctors)


def distance_km(lat1, lon1, lat2, lon2):
    import math
    r = 6371.0
    p1, p2 = math.radians(lat1), math.radians(lat2)
    dp = p2 - p1
    dl = math.radians(lon2 - lon1)
    a = math.sin(dp / 2) ** 2 + math.cos(p1) * math.cos(p2) * math.sin(dl / 2) ** 2
    return 2 * r * math.asin(math.sqrt(a))


def fetch_overpass(lat, lon, radius):
    q = (
        "[out:json][timeout:20];("
        f'nwr(around:{radius},{lat},{lon})["healthcare:speciality"~"dermat",i];'
        f'nwr(around:{radius},{lat},{lon})["name"~"skin|derma|cosmetic",i]'
        '["amenity"~"doctors|clinic|hospital"];'
        ");out center tags 60;"
    )
    body = urllib.parse.urlencode({"data": q}).encode()
    last = None
    for url in OVERPASS_URLS:
        try:
            req = urllib.request.Request(url, data=body)
            with urllib.request.urlopen(req, timeout=25) as r:
                return json.loads(r.read().decode("utf-8"))
        except Exception as e:
            last = e
    raise last


@app.route("/dermatologists", methods=["GET"])
def dermatologists():
    try:
        lat = float(request.args.get("lat", ""))
        lon = float(request.args.get("lon", ""))
    except ValueError:
        return jsonify({"error": "lat and lon are needed"}), 400

    key = (round(lat, 2), round(lon, 2))
    hit = _derm_cache.get(key)
    if hit and time.time() - hit[0] < CACHE_SECONDS:
        return jsonify({"doctors": hit[1]})

    try:
        data = fetch_overpass(lat, lon, 15000)
    except Exception as e:
        print("overpass error:", type(e).__name__, str(e)[:200])
        return jsonify({"error": "doctor search unavailable"}), 503

    doctors, seen = [], set()
    for el in data.get("elements", []):
        t = el.get("tags", {})
        name = (t.get("name") or "").strip()
        if not name or name in seen:
            continue
        seen.add(name)
        c = el.get("center") or {}
        elat = el.get("lat", c.get("lat"))
        elon = el.get("lon", c.get("lon"))
        if elat is None or elon is None:
            continue
        parts = [t.get("addr:housenumber"), t.get("addr:street"),
                 t.get("addr:suburb") or t.get("addr:neighbourhood"),
                 t.get("addr:city")]
        address = ", ".join(p for p in parts if p) or t.get("addr:full", "")
        doctors.append({
            "name": name,
            "place": t.get("operator") or t.get("amenity", "").capitalize(),
            "address": address,
            "phone": (t.get("phone") or t.get("contact:phone") or "").strip(),
            "website": (t.get("website") or t.get("contact:website") or "").strip(),
            "distance_km": round(distance_km(lat, lon, elat, elon), 1),
            "lat": elat,
            "lon": elon,
        })

    doctors.sort(key=lambda d: d["distance_km"])
    doctors = doctors[:30]
    _derm_cache[key] = (time.time(), doctors)
    return jsonify({"doctors": doctors})


# ---------------------------------------------------------------------------
# Product picture and price: read from the shop page itself (cached a day).
# Best effort: if a shop hides them, the app shows an icon / "see shop".
# ---------------------------------------------------------------------------
import html as _html
import re
from concurrent.futures import ThreadPoolExecutor, wait

_info_cache = {}  # page url -> (time, {"image":..., "price":...})
_pool = ThreadPoolExecutor(max_workers=12)
_META = r'<meta[^>]+(?:property|name)=["\']%s["\'][^>]*content=["\']([^"\']+)'
_META_REV = r'<meta[^>]+content=["\']([^"\']+)["\'][^>]*(?:property|name)=["\']%s["\']'


def _meta(page, key):
    for pattern in (_META % key, _META_REV % key):
        m = re.search(pattern, page, re.I)
        if m:
            return _html.unescape(m.group(1)).strip()
    return ""


def _to_number(text):
    try:
        return float(str(text).replace(",", "").strip())
    except ValueError:
        return None


def _find_price(page):
    # 1) meta tags (most shops)
    cur = _meta(page, "product:price:currency") or _meta(page, "og:price:currency")
    for key in ("product:price:amount", "og:price:amount"):
        amount = _to_number(_meta(page, key))
        if amount and (not cur or cur.upper() in ("BDT", "TK")):
            return amount
    # 2) JSON-LD product data
    for block in re.findall(r'<script[^>]+application/ld\+json[^>]*>(.*?)</script>',
                            page, re.I | re.S):
        if "price" not in block.lower():
            continue
        m = re.search(r'"(?:price|lowPrice)"\s*:\s*"?([0-9][0-9,\.]*)', block)
        if not m:
            continue
        c = re.search(r'"priceCurrency"\s*:\s*"([A-Za-z]+)"', block)
        if c and c.group(1).upper() not in ("BDT", "TK"):
            continue
        amount = _to_number(m.group(1))
        if amount:
            return amount
    return None


def page_info(url):
    hit = _info_cache.get(url)
    if hit and time.time() - hit[0] < CACHE_SECONDS:
        return hit[1]
    info = {"image": "", "price": None}
    try:
        req = urllib.request.Request(url, headers={
            "User-Agent": "Mozilla/5.0 (compatible; SkintelStudentProject)",
            "Accept": "text/html",
        })
        with urllib.request.urlopen(req, timeout=6) as r:
            page = r.read(600000).decode("utf-8", "ignore")
        info["image"] = _meta(page, "og:image")
        info["price"] = _find_price(page)
    except Exception as e:
        print("page error:", type(e).__name__, url[:60])
    _info_cache[url] = (time.time(), info)
    return info


def fill_product(p):
    """Adds image, per-shop price and the lowest price to a product."""
    image, prices = "", []
    for l in p["links"]:
        info = page_info(l["url"])
        l["price"] = info["price"]
        if info["price"]:
            prices.append(info["price"])
        if not image and info["image"]:
            image = info["image"]
    p["image"] = image
    p["price_min"] = min(prices) if prices else None


@app.route("/recommendations", methods=["GET"])
def recommendations():
    skin = request.args.get("skin_type", "").strip().capitalize()
    origin = request.args.get("origin", "local").strip().lower()
    category = request.args.get("category", "").strip()
    if origin not in ("local", "imported"):
        origin = "local"
    if skin not in SKIN_TYPES:
        skin = ""
    items = catalog.recommend(skin, origin, category)
    # Look up pictures and prices in parallel. Slow ones finish in the
    # background and are ready next time (results are cached).
    futures = [_pool.submit(fill_product, p) for p in items]
    wait(futures, timeout=20)
    for p in items:
        p.setdefault("image", "")
        p.setdefault("price_min", None)
        for l in p["links"]:
            l.setdefault("price", None)
    return jsonify({"products": items})


# ---------------------------------------------------------------------------
# Product picture for the shop screen.
# The app asks: /product_image?name=...&brand=...
# Steps for every product:
#   1) Find the product in catalog.py and read the picture (og:image) from
#      its shop page (Shajgoj, Arogga, Rokomari). This is the exact picture.
#   2) Search Google Shopping (SerpAPI): strict title match, then softer.
#   3) No good match: use a search picture that no other product uses yet,
#      so different products get different pictures.
#   4) Still nothing: answer 404 and the app shows the colour icon.
# Pictures are saved in image_cache_v5.json (one lookup per product).
# ---------------------------------------------------------------------------
import threading
import zlib

_BASE = os.path.dirname(os.path.abspath(__file__))
IMAGE_CACHE_FILE = os.path.join(_BASE, "image_cache_v5.json")
OLD_CACHE_FILE = os.path.join(_BASE, "image_cache_v2.json")  # only strict matches
_image_lock = threading.Lock()
_serp_gate = threading.Semaphore(3)  # max 3 searches at the same time
_image_urls = {}  # search text -> picture link
_image_bytes = {}  # picture link -> (content type, bytes)

for _file in (OLD_CACHE_FILE, IMAGE_CACHE_FILE):
    try:
        with open(_file, "r", encoding="utf-8") as _f:
            for _k, _v in json.load(_f).items():
                if _v:
                    _image_urls[_k] = _v
    except Exception:
        pass

_used_urls = set(_image_urls.values())  # pictures already given to a product

_STOP_WORDS = {"the", "and", "for", "with", "of", "demo", "listing", "by"}


def _save_image_cache():
    try:
        with open(IMAGE_CACHE_FILE, "w", encoding="utf-8") as f:
            json.dump(_image_urls, f)
    except Exception as e:
        print("image cache save error:", type(e).__name__)


def _words(text):
    return [w for w in re.findall(r"[a-z0-9]+", text.lower())
            if w not in _STOP_WORDS and len(w) > 1]


def _squash(text):
    return re.sub(r"[^a-z0-9]", "", text.lower())


def fetch_shopping_retry(query):
    """SerpAPI search, max 3 at a time, one retry if it fails."""
    last = None
    for _ in range(2):
        try:
            with _serp_gate:
                return fetch_shopping(query)
        except Exception as e:
            last = e
    raise last


def pick_best_image(results, name, brand, need):
    """Best result whose title has the brand and at least `need` (0 to 1)
    of the product name words. Returns the picture link or ''."""
    brand_key = _squash(brand)
    brand_words = set(_words(brand))
    name_words = [w for w in _words(name) if w not in brand_words]

    best_url, best_score = "", -1.0
    for r in results:
        title = str(r.get("title", ""))
        thumb = str(r.get("thumbnail", "")).strip()
        if not thumb.startswith("http"):
            continue
        if brand_key and brand_key not in _squash(title):
            continue
        title_words = set(_words(title))
        if name_words:
            score = sum(1 for w in name_words if w in title_words) / len(name_words)
        else:
            score = 1.0
        if score > best_score:
            best_url, best_score = thumb, score

    if best_url and best_score >= need:
        return best_url
    return ""


def pick_unused(results, key):
    """A search picture that no other product has yet. If all are used,
    still pick one (chosen by the product name)."""
    thumbs = []
    for r in results:
        thumb = str(r.get("thumbnail", "")).strip()
        if thumb.startswith("http") and thumb not in thumbs:
            thumbs.append(thumb)
    if not thumbs:
        return ""
    fresh = [t for t in thumbs if t not in _used_urls]
    pool = fresh or thumbs
    return pool[zlib.crc32(key.encode("utf-8")) % len(pool)]


def catalog_picture(name, brand):
    """Picture from the shop page of the same product in catalog.py."""
    name_words = _words(name)
    brand_key = _squash(brand)
    if not name_words:
        return ""
    best_urls, best_score = [], 0.0
    for item in catalog._ITEMS:
        c_name, c_brand, urls = item[0], item[1], item[6]
        c_key = _squash(c_brand)
        if brand_key and c_key and brand_key not in c_key and c_key not in brand_key:
            continue
        c_words = set(_words(c_name))
        score = sum(1 for w in name_words if w in c_words) / len(name_words)
        if score > best_score:
            best_urls, best_score = urls, score
    if best_score < 0.8:
        return ""
    for u in best_urls:
        img = page_info(u).get("image", "")
        if img.startswith("http"):
            return img
    return ""


def find_image_url(name, brand):
    name = name.replace("Demo listing.", "").strip()
    if brand and brand.lower() not in name.lower():
        query = f"{brand} {name}"
    else:
        query = name
    key = query.lower().strip()
    if not key:
        return ""
    if key in _image_urls:
        return _image_urls[key]

    url = ""

    # Step 1: exact picture from the shop page (no SerpAPI needed).
    try:
        url = catalog_picture(name, brand)
    except Exception as e:
        print("catalog picture error:", type(e).__name__)
    if url:
        print(f"image ok (shop page): {brand} / {name}")

    # Step 2: Google Shopping search.
    results = []
    if not url and os.environ.get("SERPAPI_API_KEY"):
        try:
            data = fetch_shopping_retry(query)
            results = data.get("shopping_results", [])
        except Exception as e:
            print("image search error:", type(e).__name__, str(e)[:120])
            return ""  # do not save, try again next time
        for need in (0.6, 0.3):
            url = pick_best_image(results, name, brand, need)
            if url:
                print(f"image ok (search match {need}): {brand} / {name}")
                break

        # Step 3: a picture nobody else uses yet.
        if not url:
            if not results and brand:
                try:
                    results = fetch_shopping_retry(f"{brand} skin care").get(
                        "shopping_results", [])
                except Exception as e:
                    print("brand search error:", type(e).__name__, str(e)[:120])
            with _image_lock:
                url = pick_unused(results, key)
            if url:
                print(f"image ok (similar picture): {brand} / {name}")

    if not url:
        print(f"image NOT found: {brand} / {name}")
        return ""

    with _image_lock:
        _image_urls[key] = url
        _used_urls.add(url)
        _save_image_cache()
    return url


def download_image(url):
    hit = _image_bytes.get(url)
    if hit:
        return hit
    req = urllib.request.Request(url, headers={
        "User-Agent": "Mozilla/5.0 (compatible; SkintelStudentProject)",
    })
    with urllib.request.urlopen(req, timeout=10) as r:
        ctype = r.headers.get("Content-Type", "image/jpeg")
        data = r.read(3_000_000)
    if len(_image_bytes) > 300:
        _image_bytes.clear()
    _image_bytes[url] = (ctype, data)
    return ctype, data


@app.route("/product_image", methods=["GET"])
def product_image():
    name = request.args.get("name", "").strip()
    brand = request.args.get("brand", "").strip()
    url = find_image_url(name, brand)
    if not url:
        return "", 404
    try:
        ctype, data = download_image(url)
    except Exception as e:
        print("image download error:", type(e).__name__)
        return "", 404
    return Response(
        data,
        mimetype=ctype,
        headers={"Cache-Control": "public, max-age=86400"},
    )


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