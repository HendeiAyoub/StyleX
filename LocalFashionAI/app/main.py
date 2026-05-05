from __future__ import annotations

import hashlib
import json
import math
import sqlite3
from pathlib import Path
from typing import Any, Optional

from fastapi import FastAPI
from pydantic import BaseModel


BASE_DIR = Path(__file__).resolve().parents[1]
DB_PATH = BASE_DIR / "stylex_ai.sqlite3"

app = FastAPI(title="StyleX Local Fashion AI", version="1.0-local")


SEED_PRODUCTS = [
    {
        "product_id": "1",
        "product_name": "Fjallraven Foldsack Backpack",
        "category": "men's clothing",
        "category_id": 1,
        "image_url": "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_t.png",
        "price": 109.95,
        "colors": ["#1f2937", "#6b7280", "#d1d5db"],
        "likes_count": 120,
        "avg_rating": 3.9,
    },
    {
        "product_id": "2",
        "product_name": "Mens Casual Premium Slim Fit T-Shirt",
        "category": "men's clothing",
        "category_id": 1,
        "image_url": "https://fakestoreapi.com/img/71-3HjGNDUL._AC_SY879._SX._UX._SY._UY_t.png",
        "price": 22.30,
        "colors": ["#f8fafc", "#111827", "#cbd5e1"],
        "likes_count": 259,
        "avg_rating": 4.1,
    },
    {
        "product_id": "3",
        "product_name": "Mens Cotton Jacket",
        "category": "men's clothing",
        "category_id": 1,
        "image_url": "https://fakestoreapi.com/img/71li-ujtlUL._AC_UX679_t.png",
        "price": 55.99,
        "colors": ["#b45309", "#78350f", "#f5f5dc"],
        "likes_count": 500,
        "avg_rating": 4.7,
    },
    {
        "product_id": "4",
        "product_name": "Mens Casual Slim Fit",
        "category": "men's clothing",
        "category_id": 1,
        "image_url": "https://fakestoreapi.com/img/71YXzeOuslL._AC_UY879_t.png",
        "price": 15.99,
        "colors": ["#111827", "#374151", "#f9fafb"],
        "likes_count": 430,
        "avg_rating": 2.1,
    },
    {
        "product_id": "5",
        "product_name": "Women's Legends Chain Bracelet",
        "category": "jewelery",
        "category_id": 2,
        "image_url": "https://fakestoreapi.com/img/71pWzhdJNwL._AC_UL640_QL65_ML3_t.png",
        "price": 695.00,
        "colors": ["#d4af37", "#c0c0c0", "#111827"],
        "likes_count": 400,
        "avg_rating": 4.6,
    },
    {
        "product_id": "6",
        "product_name": "Solid Gold Petite Micropave",
        "category": "jewelery",
        "category_id": 2,
        "image_url": "https://fakestoreapi.com/img/61sbMiUnoGL._AC_UL640_QL65_ML3_t.png",
        "price": 168.00,
        "colors": ["#d4af37", "#fff7ed", "#facc15"],
        "likes_count": 70,
        "avg_rating": 3.9,
    },
    {
        "product_id": "7",
        "product_name": "White Gold Plated Princess Ring",
        "category": "jewelery",
        "category_id": 2,
        "image_url": "https://fakestoreapi.com/img/71YAIFU48IL._AC_UL640_QL65_ML3_t.png",
        "price": 9.99,
        "colors": ["#f8fafc", "#c0c0c0", "#e5e7eb"],
        "likes_count": 400,
        "avg_rating": 3.0,
    },
    {
        "product_id": "8",
        "product_name": "Rose Gold Plated Earrings",
        "category": "jewelery",
        "category_id": 2,
        "image_url": "https://fakestoreapi.com/img/51UDEzMJVpL._AC_UL640_QL65_ML3_t.png",
        "price": 10.99,
        "colors": ["#b76e79", "#f5e6e8", "#111827"],
        "likes_count": 100,
        "avg_rating": 1.9,
    },
    {
        "product_id": "15",
        "product_name": "Women's 3-in-1 Snowboard Jacket",
        "category": "women's clothing",
        "category_id": 3,
        "image_url": "https://fakestoreapi.com/img/51Y5NI-I5jL._AC_UX679_t.png",
        "price": 56.99,
        "colors": ["#7f1d1d", "#111827", "#f8fafc"],
        "likes_count": 235,
        "avg_rating": 2.6,
    },
    {
        "product_id": "16",
        "product_name": "Women's Faux Leather Moto Jacket",
        "category": "women's clothing",
        "category_id": 3,
        "image_url": "https://fakestoreapi.com/img/81XH0e8fefL._AC_UY879_t.png",
        "price": 29.95,
        "colors": ["#111827", "#374151", "#94a3b8"],
        "likes_count": 340,
        "avg_rating": 2.9,
    },
    {
        "product_id": "17",
        "product_name": "Women's Striped Rain Jacket",
        "category": "women's clothing",
        "category_id": 3,
        "image_url": "https://fakestoreapi.com/img/71HblAHs5xL._AC_UY879_-2t.png",
        "price": 39.99,
        "colors": ["#2563eb", "#f8fafc", "#111827"],
        "likes_count": 679,
        "avg_rating": 3.8,
    },
    {
        "product_id": "18",
        "product_name": "Women's Short Sleeve Boat Neck",
        "category": "women's clothing",
        "category_id": 3,
        "image_url": "https://fakestoreapi.com/img/71z3kpMAYsL._AC_UY879_t.png",
        "price": 9.85,
        "colors": ["#ef4444", "#f8fafc", "#fca5a5"],
        "likes_count": 130,
        "avg_rating": 4.7,
    },
    {
        "product_id": "19",
        "product_name": "Women's Short Sleeve Moisture Top",
        "category": "women's clothing",
        "category_id": 3,
        "image_url": "https://fakestoreapi.com/img/51eg55uWmdL._AC_UX679_t.png",
        "price": 7.95,
        "colors": ["#f8fafc", "#e5e7eb", "#111827"],
        "likes_count": 146,
        "avg_rating": 4.5,
    },
    {
        "product_id": "20",
        "product_name": "Women's Casual Cotton T-Shirt",
        "category": "women's clothing",
        "category_id": 3,
        "image_url": "https://fakestoreapi.com/img/61pHAEJ4NML._AC_UX679_t.png",
        "price": 12.99,
        "colors": ["#be123c", "#f9a8d4", "#f8fafc"],
        "likes_count": 145,
        "avg_rating": 3.6,
    },
]


class ImageRequest(BaseModel):
    image_url: str
    product_id: str
    product_name: str = "Unknown Product"
    category_id: int = 0
    category_name: str = "unknown"


class RecommendRequest(BaseModel):
    product_id: str
    top_n: int = 5


class UserHistoryRecommendRequest(BaseModel):
    user_history: list[dict[str, Any]] = []
    top_n: int = 10


class SearchRequest(BaseModel):
    query_text: str
    top_n: int = 20
    category_name: str = ""


class StyleRequest(BaseModel):
    wardrobe: list[dict[str, Any]] = []
    candidate_product_id: str


class ChatbotRequest(BaseModel):
    message: str
    image_url: Optional[str] = ""
    chat_history: list[dict[str, Any]] = []


def connect() -> sqlite3.Connection:
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def embedding_for(*parts: str, size: int = 32) -> list[float]:
    seed = "|".join(parts).encode("utf-8")
    values: list[float] = []
    counter = 0
    while len(values) < size:
        digest = hashlib.sha256(seed + str(counter).encode("utf-8")).digest()
        values.extend(round((byte / 255.0), 6) for byte in digest)
        counter += 1
    return values[:size]


def color_label(hex_code: str) -> str:
    palette = {
        "black": ["#111827", "#1f2937", "#374151"],
        "white": ["#f8fafc", "#f9fafb", "#ffffff"],
        "gray": ["#6b7280", "#94a3b8", "#cbd5e1", "#d1d5db", "#e5e7eb", "#c0c0c0"],
        "gold": ["#d4af37", "#facc15"],
        "beige": ["#f5f5dc", "#fff7ed"],
        "red": ["#7f1d1d", "#ef4444", "#be123c", "#fca5a5", "#f9a8d4"],
        "blue": ["#2563eb"],
        "brown": ["#b45309", "#78350f"],
        "rose": ["#b76e79", "#f5e6e8"],
    }
    for label, values in palette.items():
        if hex_code.lower() in values:
            return label
    return "mixed"


def normalize_colors(colors: list[str]) -> list[dict[str, Any]]:
    dominance = [54.0, 28.0, 18.0, 10.0, 6.0]
    normalized = []
    for index, hex_code in enumerate(colors[:5]):
        value = hex_code.lstrip("#")
        r, g, b = int(value[0:2], 16), int(value[2:4], 16), int(value[4:6], 16)
        normalized.append(
            {
                "hex_code": hex_code,
                "rgb_r": r,
                "rgb_g": g,
                "rgb_b": b,
                "dominance_percentage": dominance[index],
                "color_label": color_label(hex_code),
            }
        )
    return normalized


def init_db() -> None:
    with connect() as conn:
        conn.execute(
            """
            create table if not exists products (
              product_id text primary key,
              product_name text not null,
              category text not null,
              category_id integer not null,
              image_url text not null,
              price real not null,
              colors_json text not null,
              embedding_json text not null,
              clip_embedding_json text not null,
              likes_count integer not null default 0,
              avg_rating real not null default 0
            )
            """
        )
        for product in SEED_PRODUCTS:
            conn.execute(
                """
                insert or ignore into products (
                  product_id, product_name, category, category_id, image_url, price,
                  colors_json, embedding_json, clip_embedding_json, likes_count, avg_rating
                ) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    product["product_id"],
                    product["product_name"],
                    product["category"],
                    product["category_id"],
                    product["image_url"],
                    product["price"],
                    json.dumps(normalize_colors(product["colors"])),
                    json.dumps(embedding_for(product["product_name"], product["category"], size=32)),
                    json.dumps(embedding_for("clip", product["product_name"], product["category"], size=32)),
                    product["likes_count"],
                    product["avg_rating"],
                ),
            )
        conn.commit()


def row_to_product(row: sqlite3.Row) -> dict[str, Any]:
    return {
        "product_id": row["product_id"],
        "product_name": row["product_name"],
        "category": row["category"],
        "category_id": row["category_id"],
        "image_url": row["image_url"],
        "price": row["price"],
        "colors": json.loads(row["colors_json"]),
        "embedding": json.loads(row["embedding_json"]),
        "clip_embedding": json.loads(row["clip_embedding_json"]),
        "likes_count": row["likes_count"],
        "avg_rating": row["avg_rating"],
    }


def all_products() -> list[dict[str, Any]]:
    with connect() as conn:
        rows = conn.execute("select * from products").fetchall()
    return [row_to_product(row) for row in rows]


def get_product(product_id: str) -> Optional[dict[str, Any]]:
    with connect() as conn:
        row = conn.execute("select * from products where product_id = ?", (product_id,)).fetchone()
    return row_to_product(row) if row else None


def cosine_similarity(a: list[float], b: list[float]) -> float:
    dot = sum(x * y for x, y in zip(a, b))
    norm_a = math.sqrt(sum(x * x for x in a))
    norm_b = math.sqrt(sum(y * y for y in b))
    if norm_a == 0 or norm_b == 0:
        return 0
    return dot / (norm_a * norm_b)


def color_overlap(left: list[dict[str, Any]], right: list[dict[str, Any]]) -> float:
    left_labels = {item.get("color_label", "") for item in left}
    right_labels = {item.get("color_label", "") for item in right}
    if not left_labels or not right_labels:
        return 0
    return len(left_labels & right_labels) / max(len(left_labels), len(right_labels))


def recommendation_score(query: dict[str, Any], candidate: dict[str, Any]) -> float:
    visual = cosine_similarity(query["embedding"], candidate["embedding"])
    color = color_overlap(query["colors"], candidate["colors"])
    popularity = min(candidate["likes_count"] / 700, 1) * 0.5 + (candidate["avg_rating"] / 5) * 0.5
    category = 1 if query["category"] == candidate["category"] else 0
    return (0.55 * visual) + (0.2 * color) + (0.15 * popularity) + (0.1 * category)


def recommendation_payload(product: dict[str, Any], score: float) -> dict[str, Any]:
    return {
        "product_id": product["product_id"],
        "product_name": product["product_name"],
        "similarity_score": round(score, 4),
        "colors": product["colors"],
        "category": product["category"],
        "image_url": product["image_url"],
        "price": product["price"],
    }


@app.on_event("startup")
def on_startup() -> None:
    init_db()


@app.get("/")
def root() -> dict[str, str]:
    return {"status": "Fashion AI API is running", "version": "1.0-local"}


@app.get("/products")
def products() -> dict[str, Any]:
    catalog = all_products()
    return {"total": len(catalog), "products": [recommendation_payload(item, 1.0) for item in catalog]}


@app.post("/extract-features")
def extract_features(request: ImageRequest) -> dict[str, Any]:
    colors = normalize_colors(["#f8fafc", "#111827", "#d1d5db"])
    embedding = embedding_for(request.product_name, request.category_name, request.image_url, size=32)
    clip_embedding = embedding_for("clip", request.product_name, request.category_name, request.image_url, size=32)
    with connect() as conn:
        conn.execute(
            """
            insert or replace into products (
              product_id, product_name, category, category_id, image_url, price,
              colors_json, embedding_json, clip_embedding_json, likes_count, avg_rating
            ) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                request.product_id,
                request.product_name,
                request.category_name,
                request.category_id,
                request.image_url,
                0,
                json.dumps(colors),
                json.dumps(embedding),
                json.dumps(clip_embedding),
                0,
                0,
            ),
        )
        total = conn.execute("select count(*) from products").fetchone()[0]
        conn.commit()
    return {
        "product_id": request.product_id,
        "colors": colors,
        "category": request.category_name,
        "embedding_preview": embedding[:10],
        "status": "success",
        "total_products_in_db": total,
    }


@app.post("/get-recommendations")
def get_recommendations(request: RecommendRequest) -> dict[str, Any]:
    query = get_product(request.product_id)
    if not query:
        return {"error": "Product not found", "status": "failed"}
    ranked = []
    for item in all_products():
        if item["product_id"] == request.product_id:
            continue
        ranked.append((item, recommendation_score(query, item)))
    ranked.sort(key=lambda pair: pair[1], reverse=True)
    return {
        "query_product": request.product_id,
        "recommendations": [recommendation_payload(item, score) for item, score in ranked[: request.top_n]],
        "status": "success",
    }


@app.post("/ai/recommend")
def recommend_for_user(request: UserHistoryRecommendRequest) -> dict[str, Any]:
    catalog = all_products()
    if not request.user_history:
        trending = sorted(catalog, key=lambda item: (item["likes_count"], item["avg_rating"]), reverse=True)
        return {"recommendations": [recommendation_payload(item, 1.0) for item in trending[: request.top_n]], "status": "success"}
    history_ids = {str(item.get("product_id")) for item in request.user_history}
    history_products = [get_product(product_id) for product_id in history_ids]
    history_products = [item for item in history_products if item]
    ranked = []
    for item in catalog:
        if item["product_id"] in history_ids:
            continue
        best = max((recommendation_score(history, item) for history in history_products), default=0)
        ranked.append((item, best))
    ranked.sort(key=lambda pair: pair[1], reverse=True)
    return {"recommendations": [recommendation_payload(item, score) for item, score in ranked[: request.top_n]], "status": "success"}


@app.post("/embed-search-query")
def embed_search_query(request: SearchRequest) -> dict[str, Any]:
    query = request.query_text.lower().strip()
    query_embedding = embedding_for("text", query, size=32)
    ranked = []
    for item in all_products():
        if request.category_name and item["category"] != request.category_name:
            continue
        text = f"{item['product_name']} {item['category']} {' '.join(color['color_label'] for color in item['colors'])}".lower()
        keyword_score = sum(1 for token in query.split() if token in text) / max(len(query.split()), 1)
        vector_score = cosine_similarity(query_embedding, item["clip_embedding"])
        score = (0.55 * keyword_score) + (0.45 * vector_score)
        ranked.append((item, score))
    ranked.sort(key=lambda pair: pair[1], reverse=True)
    return {
        "query": request.query_text,
        "query_embedding": query_embedding,
        "results": [recommendation_payload(item, score) for item, score in ranked[: request.top_n]],
        "total_found": len(ranked),
        "status": "success",
    }


@app.post("/get-style-suggestion")
def get_style_suggestion(request: StyleRequest) -> dict[str, Any]:
    candidate = get_product(request.candidate_product_id)
    if not candidate:
        return {"error": "Product not found", "status": "failed"}
    colors = ", ".join(color["color_label"] for color in candidate["colors"][:2])
    wardrobe_note = "your saved wardrobe" if request.wardrobe else "simple neutral basics"
    return {
        "candidate": candidate["product_name"],
        "suggestion": {
            "style_tip": f"Pair {candidate['product_name']} with {wardrobe_note}. Its {colors} palette keeps the outfit easy to match for a clean StyleX look.",
            "best_occasion": "Casual outings, shopping days, coffee plans, and relaxed weekend looks.",
            "warning": "For formal events, balance it with a cleaner layer and avoid adding too many competing colors.",
        },
        "status": "success",
    }


@app.post("/ai/chat")
def chat(request: ChatbotRequest) -> dict[str, Any]:
    query = SearchRequest(query_text=request.message, top_n=3)
    results = embed_search_query(query)["results"]
    names = ", ".join(item["product_name"] for item in results[:2])
    response = (
        f"For that StyleX look, I would start with {names}. "
        "The local AI demo matched your request against the catalog by style words, category, color, and product similarity."
    )
    return {
        "response_text": response,
        "recommended_product_ids": [item["product_id"] for item in results],
        "status": "success",
    }
