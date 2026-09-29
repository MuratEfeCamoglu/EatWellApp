"""Downloads a small photo for every food in the search catalog.

Reads food names from lib/data/mock_data.dart (search catalog only) and
lib/data/extra_foods.dart, looks each one up on Wikipedia, and saves a
256x256 center-cropped JPEG to assets/foods/<slug>.jpg. Recipe titles from
lib/data/recipes.dart get an 800x600 photo in assets/recipes/<slug>.jpg. Images come from
Wikimedia Commons (freely licensed). Existing files are skipped, so the
script can be re-run to fill gaps.

    python tool/fetch_food_images.py
"""

import io
import pathlib
import re
import time

import requests
from PIL import Image

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "foods"
RECIPES_OUT = ROOT / "assets" / "recipes"
UA = {"User-Agent": "DengeApp-dev/1.0 (food image fetcher)"}

# Explicit Wikipedia page titles, tried before a free-text search. Each
# value is a list of (language, title) pairs tried in order.
OVERRIDES = {
    "Menemen": [("en", "Menemen (food)"), ("tr", "Menemen (yemek)")],
    "Haşlanmış Yumurta": [("en", "Boiled egg")],
    "Beyaz Peynir": [("en", "Beyaz peynir")],
    "Kaşar Peyniri": [("en", "Kashkaval")],
    "Zeytin (Siyah)": [("en", "Kalamata olive"), ("en", "Olive")],
    "Bal": [("en", "Honey")],
    "Reçel (Kayısı)": [("en", "Fruit preserves")],
    "Tereyağı": [("en", "Butter")],
    "Domates": [("en", "Tomato")],
    "Salatalık": [("en", "Cucumber")],
    "Sucuk (Izgara)": [("en", "Sujuk")],
    "Simit": [("tr", "Simit")],
    "Yulaf Ezmesi": [("en", "Porridge")],
    "Süt (Tam Yağlı)": [("en", "Milk")],
    "Çay": [("en", "Turkish tea")],
    "Kahve (Sade)": [("en", "Coffee")],
    "Tam Buğday Ekmeği": [("en", "Whole wheat bread")],
    "Yoğurt": [("en", "Yogurt")],
    "Izgara Tavuk Göğsü": [("en", "Barbecue chicken"), ("en", "Chicken as food")],
    "Mercimek Çorbası": [("en", "Lentil soup")],
    "Fırında Somon": [("en", "Fish steak"), ("en", "Salmon as food")],
    "Izgara Köfte": [("en", "Köfte")],
    "Kuru Fasulye": [("en", "Kuru fasulye")],
    "Pilav (Pirinç)": [("en", "Pilaf")],
    "Karnıyarık": [("en", "Karnıyarık")],
    "Tavuk Sote": [("en", "Stir frying")],
    "Çoban Salata": [("en", "Shepherd's salad")],
    "Mantı": [("en", "Manti (food)")],
    "Lahmacun": [("en", "Lahmacun")],
    "Kuru Kayısı": [("en", "Dried apricot")],
    "Sahanda Yumurta": [("en", "Fried egg")],
    "Sucuklu Yumurta": [("tr", "Sucuklu yumurta"), ("en", "Sujuk")],
    "Pastırmalı Yumurta": [("en", "Pastirma")],
    "Omlet": [("en", "Omelette")],
    "Çılbır": [("en", "Çılbır")],
    "Kuymak": [("en", "Muhlama")],
    "Sigara Böreği": [("en", "Sigara böreği")],
    "Su Böreği": [("en", "Börek")],
    "Kol Böreği": [("tr", "Börek")],
    "Gözleme (Peynirli)": [("en", "Gözleme")],
    "Pişi": [("en", "Pişi")],
    "Poğaça": [("en", "Pogača")],
    "Açma": [("en", "Açma")],
    "Bazlama": [("en", "Bazlama")],
    "Kaşarlı Tost": [("en", "Grilled cheese")],
    "Kaymak": [("en", "Kaymak")],
    "Tahin Pekmez": [("en", "Tahini")],
    "Üzüm Pekmezi": [("tr", "Pekmez"), ("en", "Grape syrup")],
    "Lor Peyniri": [("en", "Lor (cheese)"), ("en", "Ricotta")],
    "Tulum Peyniri": [("en", "Tulum cheese")],
    "Hellim Peyniri (Izgara)": [("en", "Halloumi")],
    "Labne": [("en", "Strained yogurt")],
    "Yeşil Zeytin": [("en", "Nocellara del Belice"), ("en", "Cerignola olive"), ("en", "Olive")],
    "Acuka": [("en", "Muhammara")],
    "Ceviz": [("en", "Walnut")],
    "Fıstık Ezmesi": [("en", "Peanut butter")],
    "Avokado": [("en", "Avocado")],
    "Muz": [("en", "Banana")],
    "Portakal Suyu": [("en", "Orange juice")],
    "Granola": [("en", "Granola")],
    "Pankek": [("en", "Pancake")],
    "Krep": [("en", "Crêpe")],
    "Kruvasan": [("en", "Croissant")],
    "Türk Kahvesi": [("en", "Turkish coffee")],
    "Ezogelin Çorbası": [("en", "Ezogelin soup")],
    "Yayla Çorbası": [("en", "Yayla çorbası")],
    "Domates Çorbası": [("en", "Tomato soup")],
    "Tavuk Suyu Çorbası": [("en", "Chicken soup")],
    "İşkembe Çorbası": [("en", "İşkembe")],
    "Adana Kebap": [("en", "Adana kebabı")],
    "Urfa Kebap": [("en", "Urfa kebabı"), ("en", "Kebab")],
    "İskender Kebap": [("en", "İskender kebap")],
    "Tavuk Şiş": [("en", "Shish taouk")],
    "Kuzu Şiş": [("en", "Shish kebab")],
    "Tavuk Döner Dürüm": [("en", "Dürüm")],
    "Et Döner": [("en", "Doner kebab")],
    "Tas Kebabı": [("en", "Tas kebab")],
    "Orman Kebabı": [("tr", "Orman kebabı"), ("en", "Stew")],
    "Kuzu Tandır": [("en", "Kleftiko"), ("en", "Roast lamb")],
    "Hünkar Beğendi": [("en", "Hünkar beğendi")],
    "İnegöl Köfte": [("en", "İnegöl köfte")],
    "İçli Köfte": [("en", "Kibbeh")],
    "Tavuk Pilav": [("en", "Chicken and rice")],
    "Fırında Tavuk Baget": [("en", "Roast chicken")],
    "Kıymalı Pide": [("en", "Pide")],
    "Kaşarlı Pide": [("tr", "Pide")],
    "Çiğ Köfte": [("en", "Çiğ köfte")],
    "Balık Ekmek": [("en", "Balık ekmek")],
    "Kumpir": [("en", "Baked potato")],
    "Hamburger": [("en", "Hamburger")],
    "Pizza (Margherita)": [("en", "Pizza Margherita")],
    "Spagetti Bolonez": [("en", "Spaghetti alla bolognese"), ("en", "Bolognese sauce")],
    "Fırın Makarna": [("en", "Pastitsio")],
    "Erişte": [("en", "Erişte"), ("en", "Noodle")],
    "Hamsi Tava": [("tr", "Hamsi tava"), ("en", "Fried fish")],
    "Levrek Izgara": [("en", "Sarandeado"), ("en", "Fish as food")],
    "Çipura Izgara": [("en", "Pla pao"), ("en", "Fish as food")],
    "Karides Güveç": [("en", "Shrimp and prawn as food")],
    "Yaprak Sarma": [("en", "Sarma (food)"), ("en", "Dolma")],
    "Biber Dolması": [("en", "Stuffed peppers")],
    "İmam Bayıldı": [("en", "İmam bayıldı")],
    "Musakka": [("en", "Moussaka")],
    "Türlü": [("en", "Türlü")],
    # Turkish Wikipedia's "zeytinyağlı pırasa" search hit shows cooked
    # olive-oil green beans, which suits this dish; pırasa uses a leek photo.
    "Zeytinyağlı Taze Fasulye": [("tr", "Zeytinyağlı pırasa")],
    "Zeytinyağlı Pırasa": [("en", "Leek")],
    "Nohut Yemeği": [("en", "Chana masala"), ("en", "Chickpea")],
    "Ispanak Yemeği": [("en", "Creamed spinach"), ("en", "Spinach")],
    "Mücver": [("en", "Mücver")],
    "Zeytinyağlı Enginar": [("en", "Artichoke")],
    "Bulgur Pilavı": [("tr", "Bulgur pilavı"), ("en", "Bulgur")],
    "Mercimek Köftesi": [("en", "Mercimek köftesi")],
    "Kısır": [("en", "Kısır")],
    "Piyaz": [("en", "Piyaz")],
    "Gavurdağı Salatası": [("tr", "Gavurdağı salatası"), ("en", "Salad")],
    "Sezar Salata": [("en", "Caesar salad")],
    "Ton Balıklı Salata": [("en", "Tuna salad")],
    "Cacık": [("en", "Cacık")],
    "Haydari": [("en", "Haydari")],
    "Humus": [("en", "Hummus")],
    "Muhallebi": [("en", "Muhallebi"), ("en", "Malabi")],
    "Maraş Dondurması": [("en", "Ice cream")],
    "Tahin Helvası": [("en", "Halva")],
    "Roka Salatası": [("en", "Green salad"), ("en", "Salad")],
    "Şehriye Çorbası": [("en", "Noodle soup")],
    "Tarhana Çorbası": [("tr", "Tarhana çorbası"), ("en", "Tarhana")],
    "Mantarlı Omlet": [("en", "Omelette")],
    "Yumurtalı Ekmek": [("en", "French toast")],
    "Pastırma": [("en", "Pastirma")],
    "Kavurma": [("en", "Kavurma")],
    "Otlu Peynir": [("en", "Otlu peynir"), ("en", "Herby cheese")],
    "Dil Peyniri": [("tr", "Dil peyniri"), ("en", "String cheese")],
    "Tahin": [("en", "Tahini")],
    "Fındık Kreması": [("en", "Chocolate spread")],
    "Müsli": [("en", "Muesli")],
    "Mantar Çorbası": [("en", "Cream of mushroom soup")],
    "Sebze Çorbası": [("en", "Vegetable soup")],
    "Brokoli Çorbası": [("en", "Cream of broccoli soup"), ("en", "Broccoli")],
    "Beyran": [("en", "Beyran")],
    "Kuzu Pirzola": [("en", "Lamb chop"), ("en", "Pork chop")],
    "Beyti Kebap": [("en", "Beyti kebab")],
    "Ali Nazik": [("en", "Alinazik kebab")],
    "Testi Kebabı": [("en", "Testi kebab")],
    "Çöp Şiş": [("en", "Çöp şiş")],
    "Cağ Kebabı": [("en", "Cağ kebabı")],
    "Izgara Tavuk Kanat": [("en", "Buffalo wing")],
    "Biftek": [("en", "Steak")],
    "Kadınbudu Köfte": [("en", "Kadınbudu köfte")],
    "İzmir Köfte": [("en", "İzmir köfte")],
    "Etli Güveç": [("en", "Casserole"), ("en", "Güveç")],
    "Palamut Izgara": [("en", "Lakerda"), ("en", "Fish as food")],
    "Midye Dolma": [("en", "Midye dolma")],
    "Kalamar Tava": [("en", "Fried calamari"), ("en", "Squid as food")],
    "Uskumru Izgara": [("en", "Mackerel as food")],
    "Alabalık Izgara": [("en", "Fish as food")],
    "Barbunya Pilaki": [("en", "Pilaki"), ("en", "Borlotti bean")],
    "Kabak Dolması": [("en", "Stuffed zucchini"), ("en", "Dolma")],
    "Lahana Sarması": [("en", "Cabbage roll")],
    "Bamya": [("en", "Bamia")],
    "Şakşuka": [("tr", "Şakşuka"), ("en", "Shakshouka")],
    "Şehriyeli Pirinç Pilavı": [("en", "Rice pilaf"), ("en", "Pilaf")],
    "İç Pilav": [("tr", "İç pilav"), ("en", "Pilaf")],
    "Perde Pilavı": [("en", "Perde pilavı")],
    "Domates Soslu Makarna": [("en", "Pasta al pomodoro"), ("en", "Marinara sauce")],
    "Yeşil Mercimek Yemeği": [("en", "Lentil soup"), ("en", "Lentil")],
    "Etli Ekmek": [("en", "Etli ekmek")],
    "Çiğ Börek": [("en", "Chiburekki")],
    "Ispanaklı Börek": [("en", "Spanakopita")],
    "Kete": [("en", "Kete (bread)"), ("tr", "Kete")],
    "Kokoreç": [("en", "Kokoretsi")],
    "Tantuni": [("en", "Tantuni")],
    "Islak Hamburger": [("en", "Islak burger")],
    "Kumru": [("en", "Kumru (sandwich)")],
    "Patates Kızartması": [("en", "French fries")],
    "Sosisli Sandviç": [("en", "Hot dog")],
    "Mevsim Salatası": [("en", "Garden salad"), ("en", "Salad")],
    "Fava": [("en", "Fava (Greek dish)"), ("en", "Bessara")],
    "Acılı Ezme": [("en", "Ezme")],
    "Semizotu Salatası": [("en", "Portulaca oleracea")],
    "Rus Salatası": [("en", "Olivier salad")],
    "Patates Salatası": [("en", "Potato salad")],
    "Güllaç": [("en", "Güllaç")],
    "Keşkül": [("en", "Keşkül")],
    "Supangle": [("tr", "Supangle"), ("en", "Chocolate pudding")],
    "Tel Kadayıf": [("en", "Kadayıf"), ("en", "Kanafeh")],
    "Katmer": [("en", "Katmer")],
    "İrmik Helvası": [("en", "Sheera"), ("en", "Semolina pudding")],
    "Cheesecake": [("en", "Cheesecake")],
    "Kefir": [("en", "Kefir")],
    "Limonata": [("en", "Lemonade")],
    "Salep": [("en", "Salep")],
    "Boza": [("en", "Boza")],
    "Maden Suyu": [("en", "Carbonated water")],
    "Elma": [("en", "Apple")],
    "Portakal": [("en", "Orange (fruit)")],
    "Çilek": [("en", "Strawberry")],
    "Karpuz": [("en", "Watermelon")],
    "Üzüm": [("en", "Grape")],
    "Kuru İncir": [("en", "Dried fruit")],
    "Fındık": [("en", "Hazelnut")],
    "Badem": [("en", "Almond")],
    "Leblebi": [("en", "Leblebi")],
    "Kabak Çekirdeği": [("en", "Pumpkin seed")],
    "Etli Nohut": [("en", "Chana masala")],
    "Patlıcan Salatası": [("en", "Baba ghanoush")],
}

RECIPE_OVERRIDES = {
    "Yulaflı Meyveli Kase": [("en", "Porridge")],
    "Avokadolu Tam Buğday Tost": [("en", "Avocado toast")],
    "Fırında Somon ve Kuşkonmaz": [("en", "Fish steak"), ("en", "Salmon as food")],
    "Sigara Böreği": [("tr", "Sigara böreği")],
    "Fırında Tavuklu Sebze": [("en", "Roast chicken")],
    "Nohutlu Bulgur Pilavı": [("tr", "Bulgur pilavı")],
    "Tavuklu Sezar Salata": [("en", "Caesar salad")],
    "Nohut Salatası": [("en", "Balela"), ("en", "Chickpea")],
    "Badem ve Kuru Kayısı Karışımı": [("en", "Trail mix")],
    "Fırın Sütlaç": [("tr", "Sütlaç"), ("en", "Rice pudding")],
    "Izgara Köfte": [("en", "Köfte")],
}

TR_MAP = str.maketrans({
    "ç": "c", "Ç": "c", "ğ": "g", "Ğ": "g", "ı": "i", "I": "i", "İ": "i",
    "ö": "o", "Ö": "o", "ş": "s", "Ş": "s", "ü": "u", "Ü": "u",
})


def slug(name: str) -> str:
    # Must match foodImageSlug() in lib/data/models.dart.
    s = name.translate(TR_MAP).lower()
    return re.sub(r"[^a-z0-9]+", "_", s).strip("_")


def food_names() -> list[str]:
    mock = (ROOT / "lib/data/mock_data.dart").read_text(encoding="utf-8")
    mock = mock[mock.index("searchResults"):mock.index("barcodeCatalog")]
    pattern = re.compile(r"name: '([^']+)'")
    names = pattern.findall(mock)
    for extra in ("extra_foods.dart", "more_foods.dart"):
        names += pattern.findall((ROOT / "lib/data" / extra).read_text(encoding="utf-8"))
    return names


def api(lang: str, params: dict) -> dict:
    """Wikipedia API call that backs off when rate-limited."""
    for attempt in range(6):
        r = requests.get(f"https://{lang}.wikipedia.org/w/api.php",
                         params=params, headers=UA, timeout=20)
        if r.ok and r.headers.get("content-type", "").startswith("application/json"):
            return r.json()
        time.sleep(2 ** attempt)
    return {}


def thumb_for_title(lang: str, title: str, size: int) -> str | None:
    data = api(lang, {"action": "query", "titles": title, "prop": "pageimages",
                      "pithumbsize": size, "format": "json", "redirects": 1})
    for page in data.get("query", {}).get("pages", {}).values():
        if "thumbnail" in page:
            return page["thumbnail"]["source"]
    return None


def thumb_by_search(lang: str, query: str, size: int) -> str | None:
    data = api(lang, {"action": "query", "generator": "search", "gsrsearch": query,
                      "gsrlimit": 3, "prop": "pageimages", "pithumbsize": size,
                      "format": "json"})
    pages = sorted(data.get("query", {}).get("pages", {}).values(),
                   key=lambda p: p.get("index", 99))
    for page in pages:
        if "thumbnail" in page:
            return page["thumbnail"]["source"]
    return None


def save_cropped(url: str, dest: pathlib.Path, width: int, height: int) -> None:
    """Center-crops the image to width:height and resizes it to that size."""
    for attempt in range(6):
        r = requests.get(url, headers=UA, timeout=30)
        if r.ok:
            break
        time.sleep(2 ** attempt)
    r.raise_for_status()
    img = Image.open(io.BytesIO(r.content)).convert("RGB")
    ratio = width / height
    if img.width / img.height > ratio:
        w, h = int(img.height * ratio), img.height
    else:
        w, h = img.width, int(img.width / ratio)
    left, top = (img.width - w) // 2, (img.height - h) // 2
    img = img.crop((left, top, left + w, top + h)).resize((width, height), Image.LANCZOS)
    img.save(dest, "JPEG", quality=82, optimize=True)


def fetch_all(names, out_dir, overrides, size, width, height) -> list[str]:
    out_dir.mkdir(parents=True, exist_ok=True)
    missing = []
    for name in dict.fromkeys(names):
        dest = out_dir / f"{slug(name)}.jpg"
        if dest.exists():
            continue
        url = None
        for lang, title in overrides.get(name, []):
            url = thumb_for_title(lang, title, size)
            if url:
                break
        if not url:
            url = thumb_by_search("tr", re.sub(r"\s*\(.*?\)", "", name), size)
        if not url:
            missing.append(name)
            print(f"MISSING  {name}")
            continue
        try:
            save_cropped(url, dest, width, height)
            print(f"ok       {name} -> {dest.relative_to(ROOT)}")
        except Exception as e:  # noqa: BLE001 - report and keep going
            missing.append(name)
            print(f"FAILED   {name}: {e}")
        time.sleep(1)
    return missing


def recipe_titles() -> list[str]:
    src = (ROOT / "lib/data/recipes.dart").read_text(encoding="utf-8")
    return re.findall(r'title: "([^"]+)"', src)


def main() -> None:
    missing = fetch_all(food_names(), OUT, OVERRIDES, 400, 256, 256)
    # Recipe photos are shown as wide hero images, so fetch them larger and
    # crop to 4:3. Recipes sharing a food's name reuse its Wikipedia title.
    missing += fetch_all(recipe_titles(), RECIPES_OUT,
                         {**OVERRIDES, **RECIPE_OVERRIDES}, 1000, 800, 600)
    print(f"\n{len(missing)} missing: {missing}")


if __name__ == "__main__":
    main()
