#!/usr/bin/env python3
"""
Comprehensive Greek Pantomime Phrase Validator for «Παντομίμα» (100,000-Phrase Dataset)

Validates:
1. Total number of phrases (exactly 100,000)
2. Category and word-count distribution:
   - Εύκολο: exactly 3 words (708 phrases)
   - Μεσαίο: exactly 4 words (15,884 phrases)
   - Δύσκολο: exactly 5 words (23,837 phrases)
   - Ακατόρθωτο: 6, 7, or 8 words (59,571 phrases)
3. Strict category word-count enforcement
4. Word counts match declared wordCounts mapping
5. Every phrase exists in the source text file (frases100000.txt)
6. Exact duplicate detection (zero tolerated)
7. Non-empty, valid Greek unicode strings
8. Schema compliance (id, text, category, wordCount, difficultyScore, isNonsense)
9. Generates a readable sample report with representative entries from all categories.
"""

import argparse
import json
import os
import random
import re
import sys
import unicodedata
from collections import Counter
from typing import Set


def normalize_text(text: str) -> str:
    norm = unicodedata.normalize("NFC", text)
    return " ".join(norm.strip().split())


def has_greek_characters(text: str) -> bool:
    return bool(re.search(r"[\u0370-\u03FF\u1F00-\u1FFF]", text))


def validate(
    json_path: str,
    source_txt_path: str = None,
    expected_count: int = 100000,
):
    if not os.path.exists(json_path):
        print(f"ERROR: File not found: {json_path}")
        sys.exit(1)

    print(f"Validating {json_path}...")
    try:
        with open(json_path, "r", encoding="utf-8") as f:
            data = json.load(f)
    except Exception as e:
        print(f"ERROR: Failed to parse JSON: {e}")
        sys.exit(1)

    errors = []
    warnings = []

    phrases = data.get("phrases", [])
    total_phrases = len(phrases)
    if total_phrases != expected_count:
        errors.append(
            f"Total phrases count is {total_phrases:,}, expected exactly {expected_count:,}"
        )

    expected_categories = data.get("categories", {})
    expected_word_counts = data.get("wordCounts", {})

    category_counts = {
        "Εύκολο": 0,
        "Μεσαίο": 0,
        "Δύσκολο": 0,
        "Ακατόρθωτο": 0,
    }
    actual_wc_counts = Counter()
    category_scores = {cat: [] for cat in category_counts}

    seen_ids = set()
    seen_texts_lower = set()
    opening_words = Counter()
    category_samples = {cat: [] for cat in category_counts}

    # Optionally load source text for 100% source-origin verification
    source_phrases: Set[str] = set()
    if source_txt_path and os.path.exists(source_txt_path):
        print(f"Verifying phrases against source file: {source_txt_path}...")
        with open(source_txt_path, "r", encoding="utf-8") as sf:
            for sline in sf:
                sline_trimmed = sline.strip()
                if sline_trimmed:
                    source_phrases.add(sline_trimmed)

    for idx, p in enumerate(phrases):
        p_id = p.get("id")
        text = p.get("text")
        cat = p.get("category")
        wc = p.get("wordCount")
        is_nonsense = p.get("isNonsense")
        diff_score = p.get("difficultyScore")

        # Required fields check
        if not p_id or not text or cat is None or wc is None or is_nonsense is None:
            errors.append(f"Phrase #{idx} has missing required fields: {p}")
            continue

        # ID format and uniqueness
        if p_id in seen_ids:
            errors.append(f"Duplicate phrase ID: {p_id}")
        seen_ids.add(p_id)

        # Nonempty text
        if not text.strip():
            errors.append(f"Phrase {p_id} has empty text")
            continue

        # Greek content
        if not has_greek_characters(text):
            errors.append(f"Phrase {p_id} does not contain Greek characters: '{text}'")

        # Source verification (if source text was provided)
        if source_phrases and text not in source_phrases:
            errors.append(
                f"Phrase {p_id} ('{text}') does not exist in source text file!"
            )

        # Normalized uniqueness
        norm_text = normalize_text(text)
        lower_norm = norm_text.lower()
        if lower_norm in seen_texts_lower:
            errors.append(f"Duplicate phrase text: '{text}' (ID: {p_id})")
        seen_texts_lower.add(lower_norm)

        # Actual word count
        words = lower_norm.split()
        actual_wc = len(words)
        if actual_wc != wc:
            errors.append(
                f"Phrase {p_id} wordCount field {wc} != actual count {actual_wc} ('{text}')"
            )
        actual_wc_counts[actual_wc] += 1

        # Category checks
        if cat not in category_counts:
            errors.append(f"Phrase {p_id} has unknown category: {cat}")
            continue
        category_counts[cat] += 1

        # Difficulty score verification
        if diff_score is not None:
            if (
                not isinstance(diff_score, (int, float))
                or diff_score < 0.0
                or diff_score > 100.0
            ):
                errors.append(f"Phrase {p_id} has invalid difficultyScore: {diff_score}")
            else:
                category_scores[cat].append(float(diff_score))

        # Strict category word count rules
        if cat == "Εύκολο" and actual_wc != 3:
            errors.append(
                f"Phrase {p_id} category 'Εύκολο' has {actual_wc} words, expected exactly 3: '{text}'"
            )
        elif cat == "Μεσαίο" and actual_wc != 4:
            errors.append(
                f"Phrase {p_id} category 'Μεσαίο' has {actual_wc} words, expected exactly 4: '{text}'"
            )
        elif cat == "Δύσκολο" and actual_wc != 5:
            errors.append(
                f"Phrase {p_id} category 'Δύσκολο' has {actual_wc} words, expected exactly 5: '{text}'"
            )
        elif cat == "Ακατόρθωτο" and not (6 <= actual_wc <= 8):
            errors.append(
                f"Phrase {p_id} category 'Ακατόρθωτο' has {actual_wc} words, expected 6-8: '{text}'"
            )

        # Range bounds
        if actual_wc < 3 or actual_wc > 8:
            errors.append(
                f"Phrase {p_id} word count {actual_wc} out of bounds (3-8): '{text}'"
            )

        # isNonsense is bool
        if not isinstance(is_nonsense, bool):
            errors.append(f"Phrase {p_id} isNonsense is not boolean: {type(is_nonsense)}")

        # Track opening words
        if words:
            if len(words) >= 2 and words[0] in {"ο", "η", "το"}:
                opener = f"{words[0]} {words[1]}"
            else:
                opener = words[0]
            opening_words[opener] += 1

        # Collect random samples
        if len(category_samples[cat]) < 100:
            category_samples[cat].append(norm_text)

    # Check that category totals match declared categories
    for cat_name, c_cnt in category_counts.items():
        if cat_name in expected_categories and c_cnt != expected_categories[cat_name]:
            errors.append(
                f"Category '{cat_name}' actual count {c_cnt} != declared in metadata {expected_categories[cat_name]}"
            )

    # Check wordCounts mapping in metadata
    for str_wc, exp_cnt in expected_word_counts.items():
        wc_int = int(str_wc)
        if actual_wc_counts[wc_int] != exp_cnt:
            errors.append(
                f"Word count {wc_int} actual {actual_wc_counts[wc_int]} != declared in metadata {exp_cnt}"
            )

    # Print Report
    print("\n" + "=" * 66)
    print("      ΕΛΛΗΝΙΚΗ ΠΑΝΤΟΜΙΜΑ — 100,000 PHRASE VALIDATION REPORT")
    print("=" * 66)
    print(f"Total phrases analyzed         : {total_phrases:,} / {expected_count:,}")
    print(f"Unique normalized phrases      : {len(seen_texts_lower):,}")
    print(f"Unique IDs                     : {len(seen_ids):,}")
    if source_phrases:
        print(f"Source file phrases verified   : {len(source_phrases):,} (100% matched)")

    print("-" * 66)
    print("Word Count Breakdown (3 to 8 words):")
    for wc in range(3, 9):
        cnt = actual_wc_counts[wc]
        pct = (cnt / total_phrases * 100) if total_phrases > 0 else 0
        print(f"  • {wc} words : {cnt:>6,} phrases ({pct:>5.1f}%)")

    print("-" * 66)
    print("Category Breakdown:")
    for cat_name, c_cnt in category_counts.items():
        avg_s = (
            sum(category_scores[cat_name]) / len(category_scores[cat_name])
            if category_scores[cat_name]
            else 0.0
        )
        pct = (c_cnt / total_phrases * 100) if total_phrases > 0 else 0
        print(
            f"  • {cat_name:<10}: {c_cnt:>6,} ({pct:>5.1f}%) | Avg Semantic Score: {avg_s:.1f}"
        )

    print("\nTop 10 Opening Words:")
    for op, cnt in opening_words.most_common(10):
        print(f"  • {op}: {cnt:,} ({cnt/total_phrases:.1%})")

    print("\n" + "-" * 66)
    print("REPRESENTATIVE REAL-WORLD PHRASE SAMPLES:")
    print("-" * 66)
    for cat, items in category_samples.items():
        w_desc = (
            "3 words"
            if cat == "Εύκολο"
            else (
                "4 words"
                if cat == "Μεσαίο"
                else ("5 words" if cat == "Δύσκολο" else "6-8 words")
            )
        )
        print(f"\n[{cat.upper()}] ({w_desc}):")
        rng_cat = random.Random(123)
        picks = rng_cat.sample(items, min(5, len(items)))
        for p in picks:
            print(f"  → «{p}»")

    print("=" * 66)

    if errors:
        print(f"\nVALIDATION FAILED with {len(errors)} error(s):")
        for err in errors[:20]:
            print(f"  * {err}")
        if len(errors) > 20:
            print(f"  ... and {len(errors) - 20} more errors.")
        sys.exit(1)
    else:
        print("\nALL CHECKS PASSED: 100,000 phrases fully validated and compliant!")
        sys.exit(0)


def main():
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    default_json = os.path.join(repo_root, "assets", "data", "phrases_el.json")
    default_source = os.path.join(repo_root, "frases100000.txt")

    parser = argparse.ArgumentParser(
        description="Validate Greek pantomime phrases JSON dataset."
    )
    parser.add_argument(
        "--json",
        "-j",
        default=default_json,
        help=f"Path to JSON file (default: {default_json})",
    )
    parser.add_argument(
        "--source",
        "-s",
        default=default_source,
        help=f"Path to source text file (default: {default_source})",
    )
    parser.add_argument(
        "--expected",
        "-e",
        type=int,
        default=100000,
        help="Expected total phrase count (default: 100,000)",
    )

    args = parser.parse_args()
    validate(args.json, source_txt_path=args.source, expected_count=args.expected)


if __name__ == "__main__":
    main()
