#!/usr/bin/env python3
"""
Weighted Semantic Difficulty Scorer for Greek Pantomime Phrases.

Calculates a multidimensional semantic difficulty score (0.0 to 100.0) based on:
- Word Familiarity (25%): Common, everyday vocabulary vs specialized/rare terms.
- Semantic Abstractness (20%): Tangible physical actions vs internal mental/emotional concepts.
- Action Complexity (20%): Single direct movements vs multi-stage/balancing/challenging acts.
- Cultural Specificity (15%): Universal acts vs Greek-specific cultural customs and tropes.
- Guessability & Ambiguity (10%): Ease of inferring the prompt without spoken clues.
- Scenario Complexity (10%): Number of active semantic elements (actor, action, object, location, adverb).
"""

import re
import unicodedata
from typing import Dict, List, Tuple

# Configurable Weights (sum = 1.0)
DEFAULT_WEIGHTS = {
    "word_familiarity": 0.25,
    "semantic_abstractness": 0.20,
    "action_complexity": 0.20,
    "cultural_specificity": 0.15,
    "guessability": 0.10,
    "scenario_complexity": 0.10,
}

# Lexical Resources for Greek Charades
UNIVERSAL_HIGH_FAMILIARITY = {
    "ο", "η", "το", "τον", "την", "τους", "τις", "τα", "στο", "στη", "στον", "στην", "στα", "στους", "στις",
    "μαμά", "μπαμπάς", "παιδί", "μωρό", "παππούς", "γιαγιά", "αγόρι", "κορίτσι", "σκύλος", "γάτα", "κόκορας",
    "φαγητό", "νερό", "γάλα", "ψωμί", "μήλο", "μπανάνα", "μπάλα", "πόρτα", "σπίτι", "κρεβάτι", "καναπές",
    "τρέχει", "κοιμάται", "τρώει", "πίνει", "κλαίει", "γελάει", "πέφτει", "πηδάει", "σκύβει",
    "πλύνει", "σκουπίζει", "χορεύει", "διαβάζει", "γράφει", "ανοίγει", "κλείνει", "ψάχνει", "βρίσκει"
}

CULTURALLY_SPECIFIC_GREEK = {
    "κουμπάρος", "κουμπάρα", "πεθερά", "πεθερός", "μπατζανάκης", "συμπεθέρα", "νονός", "νονά",
    "ζεϊμπέκικο", "τσιφτετέλι", "καλαματιανό", "συρτάκι", "ικαριώτικο", "πανηγύρι", "γλέντι", "καντάδα",
    "σουβλάκια", "σουβλάκι", "μουσακάς", "παστίτσιο", "κουλουράκια", "τσουρέκι", "λουκουμάδες", "σπανακόπιτα",
    "φραπέ", "ελληνικό", "καφενείο", "λαϊκή", "φουφού", "κομπολόι", "τάβλι", "πρέφα", "μπουζούκι", "μπαγλαμάς",
    "παπάς", "καντήλι", "κουμπαράς", "φλουρί", "τσολιάς", "ευζωνας", "τσιπουράδικο", "ταβέρνα"
}

ABSTRACT_MENTAL_ACTIONS = {
    "σκέφτεται", "προβληματίζεται", "υποπτεύεται", "διαμαρτύρεται", "απορεί", "αναρωτιέται",
    "ονειρεύεται", "ξεχνάει", "θυμάται", "σχεδιάζει", "συνωμοτεί", "μετανιώνει", "νοσταλγεί",
    "αμφιβάλλει", "ελπίζει", "ζηλεύει", "συγχωρεί", "συγκεντρώνεται", "φαντάζεται", "συλλογίζεται"
}

COMPLEX_ACTION_INDICATORS = {
    "προσπαθεί", "ισορροπεί", "ισορροπήσει", "εξαφανίσει", "ξεκλειδώσει", "ξεμπερδέψει",
    "αντιγράψει", "αποφύγει", "συναρμολογήσει", "εξερευνήσει", "μεταμφιεστεί", "αποκοιμιέται",
    "ξεγλιστράει", "κουρδίζει", "ακονίζει", "πλημμυρίζει", "βραχυκυκλώνει",
    "χωρίς", "ενώ", "ώστε", "ξαφνικά", "αδέξια", "πανικόβλητος", "απεγνωσμένα"
}

class PhraseDifficultyScorer:
    def __init__(self, weights: Dict[str, float] = None):
        self.weights = weights or dict(DEFAULT_WEIGHTS)
        total = sum(self.weights.values())
        if total > 0:
            self.weights = {k: v / total for k, v in self.weights.items()}

    def score(self, phrase_text: str) -> Dict[str, float]:
        norm = unicodedata.normalize("NFC", phrase_text).lower()
        clean = re.sub(r"[^\w\s\u0370-\u03ff\u1f00-\u1fff]", "", norm)
        tokens = clean.split()

        if not tokens:
            return {
                "composite_score": 0.0,
                "word_familiarity": 100.0,
                "semantic_abstractness": 0.0,
                "action_complexity": 0.0,
                "cultural_specificity": 0.0,
                "guessability": 0.0,
                "scenario_complexity": 0.0,
            }

        # 1. Word Familiarity (0-100, 100 = most familiar)
        fam_hits = sum(1 for t in tokens if t in UNIVERSAL_HIGH_FAMILIARITY)
        specialized = sum(1 for t in tokens if len(t) > 9 and t not in UNIVERSAL_HIGH_FAMILIARITY)
        fam_score = (fam_hits / len(tokens)) * 100.0 - (specialized * 10.0)
        fam_score = max(20.0, min(100.0, fam_score))

        # 2. Semantic Abstractness (0-100, 100 = most abstract)
        abs_hits = sum(1 for t in tokens if t in ABSTRACT_MENTAL_ACTIONS)
        abstractness = min(100.0, max(5.0, abs_hits * 45.0))

        # 3. Action Complexity (0-100, 100 = most complex physical pantomime)
        comp_hits = sum(1 for t in tokens if t in COMPLEX_ACTION_INDICATORS)
        action_comp = 15.0 + (comp_hits * 35.0)
        if "προσπαθεί να" in norm:
            action_comp += 25.0
        action_comp = min(100.0, max(10.0, action_comp))

        # 4. Cultural Specificity (0-100, 100 = highly culturally nuanced)
        cult_hits = sum(1 for t in tokens if t in CULTURALLY_SPECIFIC_GREEK)
        cultural = min(100.0, cult_hits * 40.0)

        # 5. Guessability & Ambiguity (0-100, 100 = hard to guess/ambiguous)
        ambiguity = 15.0 + (abs_hits * 35.0) + (cult_hits * 15.0)
        ambiguity = min(100.0, max(5.0, ambiguity))

        # 6. Scenario Complexity (0-100, 100 = dense, multi-role scenario)
        scenario_comp = (len(tokens) * 12.0) + (comp_hits * 15.0)
        scenario_comp = min(100.0, max(10.0, scenario_comp))

        # Weighted calculation
        unfamiliarity = 100.0 - fam_score
        w = self.weights

        composite = (
            unfamiliarity * w["word_familiarity"] +
            abstractness * w["semantic_abstractness"] +
            action_comp * w["action_complexity"] +
            cultural * w["cultural_specificity"] +
            ambiguity * w["guessability"] +
            scenario_comp * w["scenario_complexity"]
        )

        return {
            "composite_score": round(min(100.0, max(0.0, composite)), 1),
            "word_familiarity": round(fam_score, 1),
            "semantic_abstractness": round(abstractness, 1),
            "action_complexity": round(action_comp, 1),
            "cultural_specificity": round(cultural, 1),
            "guessability": round(ambiguity, 1),
            "scenario_complexity": round(scenario_comp, 1),
        }
