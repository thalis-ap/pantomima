#!/usr/bin/env python3
"""
Phrase Processing Engine for «Παντομίμα»

Ingests raw Greek phrases from a text file (default: frases100000.txt), validates
and groups phrases by word count (3, 4, 5, 6, 7, 8 words), removes exact duplicates,
computes multidimensional semantic difficulty scores, and exports the final dataset
into the production JSON schema consumed by the Flutter application.

Usage:
    python3 scripts/process_phrases.py [--input frases100000.txt] [--output assets/data/phrases_el.json]
"""

import argparse
import json
import os
import sys
import time
import unicodedata
from collections import Counter, defaultdict
from typing import Dict, List, Optional, Tuple

from phrase_scorer import PhraseDifficultyScorer


def normalize_whitespace(text: str) -> str:
    """Trims leading/trailing whitespace and collapses repeated whitespace characters."""
    return " ".join(text.strip().split())


def count_words(text: str) -> int:
    """Counts words using a consistent whitespace splitting rule."""
    words = text.strip().split()
    return len(words)


def map_word_count_to_category(word_count: int) -> Optional[str]:
    """
    Maps word count to the canonical Greek Pantomime difficulty category:
    - 3 words: Εύκολο
    - 4 words: Μεσαίο
    - 5 words: Δύσκολο
    - 6, 7, 8 words: Ακατόρθωτο
    Returns None if word count is outside the valid range [3, 8].
    """
    if word_count == 3:
        return "Εύκολο"
    elif word_count == 4:
        return "Μεσαίο"
    elif word_count == 5:
        return "Δύσκολο"
    elif 6 <= word_count <= 8:
        return "Ακατόρθωτο"
    return None


def process_phrases(
    input_path: str,
    output_path: str,
    verbose: bool = True
) -> Dict[str, any]:
    """
    Processes the raw phrase text file, groups phrases by word count (3-8),
    computes difficulty scores, and writes the structured JSON file.
    """
    if not os.path.isfile(input_path):
        raise FileNotFoundError(f"Input file not found: {input_path}")

    start_time = time.time()
    scorer = PhraseDifficultyScorer()

    total_lines = 0
    empty_lines = 0
    duplicate_count = 0
    invalid_length_count = 0

    seen_exact_phrases = set()

    # Phrases organized by word count (keys: 3, 4, 5, 6, 7, 8)
    phrases_by_wc = defaultdict(list)

    with open(input_path, "r", encoding="utf-8") as f:
        for line_num, line in enumerate(f, start=1):
            total_lines += 1

            # Strip leading/trailing whitespace without altering inner content
            raw_trimmed = line.strip()

            if not raw_trimmed:
                empty_lines += 1
                continue

            # Check for exact duplicate phrases (preserving first encounter)
            if raw_trimmed in seen_exact_phrases:
                duplicate_count += 1
                continue
            seen_exact_phrases.add(raw_trimmed)

            # Count words handling repeated whitespace
            words = raw_trimmed.split()
            wc = len(words)

            if wc < 3 or wc > 8:
                invalid_length_count += 1
                continue

            # Preserves original text, accents, punctuation, and spelling
            phrases_by_wc[wc].append(raw_trimmed)

    # Calculate statistics across word counts
    valid_word_counts = [3, 4, 5, 6, 7, 8]
    count_by_wc = {wc: len(phrases_by_wc[wc]) for wc in valid_word_counts}
    total_valid = sum(count_by_wc.values())

    # Build final phrases list grouped by word count (3 -> 8)
    all_phrases = []
    category_counts = {
        "Εύκολο": 0,
        "Μεσαίο": 0,
        "Δύσκολο": 0,
        "Ακατόρθωτο": 0,
    }
    category_scores = defaultdict(list)

    phrase_id_counter = 1

    for wc in valid_word_counts:
        cat_name = map_word_count_to_category(wc)
        for phrase_text in phrases_by_wc[wc]:
            # Semantic difficulty scoring
            score_data = scorer.score(phrase_text)
            diff_score = score_data["composite_score"]

            category_counts[cat_name] += 1
            category_scores[cat_name].append(diff_score)

            phrase_entry = {
                "text": phrase_text,
            }
            all_phrases.append(phrase_entry)
            phrase_id_counter += 1

    # Prepare JSON dataset matching Flutter's schema
    dataset = {
        "version": "3.0.0",
        "description": "Authentic Greek pantomime phrases dataset sourced from frases100000.txt.",
        "sourceFile": os.path.basename(input_path),
        "totalPhrases": total_valid,
        "categories": {
            "Εύκολο": category_counts["Εύκολο"],
            "Μεσαίο": category_counts["Μεσαίο"],
            "Δύσκολο": category_counts["Δύσκολο"],
            "Ακατόρθωτο": category_counts["Ακατόρθωτο"],
        },
        "wordCounts": {
            str(wc): count_by_wc[wc] for wc in valid_word_counts
        },
        "phrases": all_phrases,
    }

    # Ensure parent output directory exists
    os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)

    with open(output_path, "w", encoding="utf-8") as out_f:
        json.dump(dataset, out_f, ensure_ascii=False, indent=2)

    elapsed = time.time() - start_time
    file_size_mb = os.path.getsize(output_path) / (1024 * 1024)

    summary = {
        "input_path": input_path,
        "output_path": output_path,
        "output_size_mb": round(file_size_mb, 2),
        "total_lines": total_lines,
        "empty_lines": empty_lines,
        "duplicates_removed": duplicate_count,
        "invalid_length_count": invalid_length_count,
        "total_valid": total_valid,
        "count_by_wc": count_by_wc,
        "category_counts": category_counts,
        "elapsed_seconds": round(elapsed, 2),
    }

    if verbose:
        print("=" * 66)
        print("     ΕΛΛΗΝΙΚΗ ΠΑΝΤΟΜΙΜΑ — PHRASE PROCESSING & EXPORT ENGINE")
        print("=" * 66)
        print(f"Input source file        : {input_path}")
        print(f"Total lines in source    : {total_lines:,}")
        print(f"Empty lines skipped      : {empty_lines:,}")
        print(f"Duplicates removed       : {duplicate_count:,}")
        print(f"Invalid lengths (<3, >8) : {invalid_length_count:,}")
        print(f"Total usable phrases     : {total_valid:,}")
        print("-" * 66)
        print("Valid phrases grouped by word count:")
        for wc in valid_word_counts:
            pct = (count_by_wc[wc] / total_valid * 100) if total_valid > 0 else 0
            print(f"  • {wc} words : {count_by_wc[wc]:>6,} phrases ({pct:>5.1f}%)")
        print("-" * 66)
        print("Category distribution:")
        for cat, count in category_counts.items():
            avg_s = (
                sum(category_scores[cat]) / len(category_scores[cat])
                if category_scores[cat]
                else 0.0
            )
            pct = (count / total_valid * 100) if total_valid > 0 else 0
            print(
                f"  • {cat:<10} : {count:>6,} phrases ({pct:>5.1f}%) | Avg Score: {avg_s:.1f}"
            )
        print("-" * 66)
        print(f"Destination JSON         : {output_path}")
        print(f"Exported JSON size       : {file_size_mb:.2f} MB")
        print(f"Processing time          : {elapsed:.2f} seconds")
        print("=" * 66)

    return summary


def main():
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    default_input = os.path.join(repo_root, "phraseis_creator", "frases100000.txt")
    if not os.path.exists(default_input):
        default_input = os.path.join(repo_root, "frases100000.txt")
    default_output = os.path.join(repo_root, "assets", "data", "phrases_el.json")

    parser = argparse.ArgumentParser(
        description="Process Greek pantomime phrases from text file into JSON dataset."
    )
    parser.add_argument(
        "--input",
        "-i",
        default=default_input,
        help=f"Path to input text file (default: {default_input})",
    )
    parser.add_argument(
        "--output",
        "-o",
        default=default_output,
        help=f"Path to output JSON file (default: {default_output})",
    )
    parser.add_argument(
        "--quiet",
        "-q",
        action="store_true",
        help="Suppress summary output",
    )

    args = parser.parse_args()
    summary = process_phrases(args.input, args.output, verbose=not args.quiet)

    if summary["total_valid"] == 0:
        print("ERROR: No valid phrases were processed!", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
