#!/usr/bin/env python3
"""
Unit and integration tests for phrase processing engine (process_phrases.py).
Tests:
- Word counting with single and repeated whitespace
- Filtering phrases with <3 or >8 words
- Deduplication of exact duplicate phrases
- Ignoring empty lines and whitespace-only lines
- Correct group sorting and category assignment
- JSON schema compatibility
"""

import json
import os
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from process_phrases import count_words, map_word_count_to_category, process_phrases


class TestPhraseProcessing(unittest.TestCase):
    def test_word_counting_rules(self):
        # Standard spacing
        self.assertEqual(count_words("Ο παππούς χορεύει"), 3)
        self.assertEqual(count_words("Ο μάγειρας ψήνει μπριζόλες"), 4)

        # Repeated whitespace (spaces and tabs)
        self.assertEqual(count_words("Ο   παππούς    χορεύει"), 3)
        self.assertEqual(count_words("  Ο \t παππούς   χορεύει  \t"), 3)

        # Bounds
        self.assertEqual(count_words("Δύο λέξεις"), 2)
        self.assertEqual(count_words("Μία δύο τρεις τέσσερις πέντε έξι επτά οκτώ εννέα"), 9)

    def test_category_mapping(self):
        self.assertEqual(map_word_count_to_category(3), "Εύκολο")
        self.assertEqual(map_word_count_to_category(4), "Μεσαίο")
        self.assertEqual(map_word_count_to_category(5), "Δύσκολο")
        self.assertEqual(map_word_count_to_category(6), "Ακατόρθωτο")
        self.assertEqual(map_word_count_to_category(7), "Ακατόρθωτο")
        self.assertEqual(map_word_count_to_category(8), "Ακατόρθωτο")
        self.assertIsNone(map_word_count_to_category(2))
        self.assertIsNone(map_word_count_to_category(9))

    def test_processing_pipeline(self):
        mock_lines = [
            # Valid 3-word
            "Ο σκύλος γαβγίζει\n",
            # Valid 4-word with extra internal whitespace
            "Η   γιαγιά   φτιάχνει   κουλουράκια\n",
            # Valid 5-word
            "Ο παππούς χορεύει στο τραπέζι\n",
            # Valid 6-word
            "Ο μάγειρας ψήνει κρέας στην ταβέρνα\n",
            # Valid 7-word
            "Ο μάγειρας ψήνει το κρέας στην ταβέρνα\n",
            # Valid 8-word
            "Ένας αστροναύτης προσπαθεί να φάει καρπούζι χωρίς βαρύτητα\n",
            # Duplicate of line 1
            "Ο σκύλος γαβγίζει\n",
            # Empty line
            "\n",
            # Whitespace-only line
            "    \t  \n",
            # Invalid < 3 words (2 words)
            "Πάρα πολύ\n",
            # Invalid > 8 words (9 words)
            "Ένα δύο τρία τέσσερα πέντε έξι επτά οκτώ εννέα\n",
        ]

        with tempfile.NamedTemporaryFile("w", encoding="utf-8", delete=False) as in_f:
            in_f.writelines(mock_lines)
            in_path = in_f.name

        with tempfile.NamedTemporaryFile("w", encoding="utf-8", delete=False) as out_f:
            out_path = out_f.name

        try:
            summary = process_phrases(in_path, out_path, verbose=False)

            # Assert summary counts
            self.assertEqual(summary["total_lines"], 11)
            self.assertEqual(summary["empty_lines"], 2)
            self.assertEqual(summary["duplicates_removed"], 1)
            self.assertEqual(summary["invalid_length_count"], 2)  # 2-word and 9-word
            self.assertEqual(summary["total_valid"], 6)

            # Assert counts by word length
            self.assertEqual(summary["count_by_wc"][3], 1)
            self.assertEqual(summary["count_by_wc"][4], 1)
            self.assertEqual(summary["count_by_wc"][5], 1)
            self.assertEqual(summary["count_by_wc"][6], 1)
            self.assertEqual(summary["count_by_wc"][7], 1)
            self.assertEqual(summary["count_by_wc"][8], 1)

            # Verify exported JSON schema
            with open(out_path, "r", encoding="utf-8") as jf:
                data = json.load(jf)

            self.assertEqual(data["totalPhrases"], 6)
            self.assertEqual(len(data["phrases"]), 6)

            phrases = data["phrases"]
            # Verify ordering by word count and texts
            self.assertEqual(phrases[0]["text"], "Ο σκύλος γαβγίζει")
            self.assertEqual(phrases[1]["text"], "Η   γιαγιά   φτιάχνει   κουλουράκια")
            self.assertEqual(phrases[2]["text"], "Ο παππούς χορεύει στο τραπέζι")
            self.assertEqual(phrases[3]["text"], "Ο μάγειρας ψήνει κρέας στην ταβέρνα")
            self.assertEqual(phrases[4]["text"], "Ο μάγειρας ψήνει το κρέας στην ταβέρνα")
            self.assertEqual(phrases[5]["text"], "Ένας αστροναύτης προσπαθεί να φάει καρπούζι χωρίς βαρύτητα")

        finally:
            if os.path.exists(in_path):
                os.remove(in_path)
            if os.path.exists(out_path):
                os.remove(out_path)


if __name__ == "__main__":
    unittest.main()
