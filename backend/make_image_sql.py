"""Finds a picture for every product in catalog.py and writes images.sql.

Run once from the project folder:
    python backend/make_image_sql.py

It opens each shop page, reads the picture address (og:image) and writes
UPDATE lines. Give images.sql to the person who owns Supabase to run in the
SQL Editor. Products without a picture keep the spa icon.
"""
import html
import os
import re
import sys
import urllib.request
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import catalog  # noqa: E402

META = r'<meta[^>]+(?:property|name)=["\']%s["\'][^>]*content=["\']([^"\']+)'
META_REV = r'<meta[^>]+content=["\']([^"\']+)["\'][^>]*(?:property|name)=["\']%s["\']'


def og_image(url):
    try:
        req = urllib.request.Request(url, headers={
            "User-Agent": "Mozilla/5.0 (compatible; SkintelStudentProject)",
            "Accept": "text/html",
        })
        with urllib.request.urlopen(req, timeout=10) as r:
            page = r.read(600000).decode("utf-8", "ignore")
    except Exception:
        return ""
    for key in ("og:image", "twitter:image"):
        for pattern in (META % key, META_REV % key):
            m = re.search(pattern, page, re.I)
            if m:
                img = html.unescape(m.group(1)).strip()
                if img.startswith("http"):
                    return img
    return ""


def find_image(item):
    name, urls = item[0], item[6]
    for u in urls:
        img = og_image(u)
        if img:
            return name, img
    return name, ""


def q(s):
    return "'" + str(s).replace("'", "''") + "'"


def main():
    items = catalog._ITEMS
    print("Looking for pictures for %d products..." % len(items))
    with ThreadPoolExecutor(max_workers=8) as pool:
        results = list(pool.map(find_image, items))

    lines, missing = [], []
    for name, img in results:
        if img:
            lines.append("update public.products set image_url = %s where name = %s;" % (q(img), q(name)))
        else:
            missing.append(name)

    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "images.sql")
    with open(out, "w", encoding="utf-8") as f:
        f.write("-- product pictures\n" + "\n".join(lines) + "\n")

    print("Found %d pictures, %d missing." % (len(lines), len(missing)))
    for n in missing:
        print("  no picture:", n)
    print("Written:", out)


if __name__ == "__main__":
    main()