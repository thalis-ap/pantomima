/// Greek localization strings for «Παντομίμα»
/// 100% authentic Greek text for all user-facing UI elements.
class GreekStrings {
  GreekStrings._();

  // App & General
  static const String appTitle = 'Παντομίμα';
  static const String appTagline =
      'Το απόλυτο παιχνίδι παρέας με δράση, γέλιο και μαντεψιές!';
  static const String offlineNotice = '100.000 φράσεις • 100% χωρίς ίντερνετ';
  static const String ok = 'Εντάξει';
  static const String cancel = 'Ακύρωση';
  static const String confirm = 'Επιβεβαίωση';
  static const String save = 'Αποθήκευση';
  static const String error = 'Σφάλμα';
  static const String retry = 'Δοκιμάστε ξανά';
  static const String loading = 'Φόρτωση φράσεων...';

  // Home Screen
  static const String teamGame = 'Ομαδικό Παιχνίδι';
  static const String teamGameSubtitle =
      'Ανταγωνιστείτε σε ομάδες με πόντους και γύρους!';
  static const String freePlay = 'Ελεύθερο Παιχνίδι';
  static const String freePlaySubtitle = 'Χαλαρή διασκέδαση χωρίς βαθμολογία!';
  static const String settings = 'Ρυθμίσεις';
  static const String settingsSubtitle = 'Ήχοι, δονήσεις, εμφάνιση και χρόνος';

  // Difficulties
  static const String easy = 'Εύκολο';
  static const String medium = 'Μεσαίο';
  static const String hard = 'Δύσκολο';
  static const String impossible = 'Ακατόρθωτο';
  static const String allDifficulties = 'Όλες οι δυσκολίες';

  // Team Setup
  static const String setupTitle = 'Ρύθμιση Ομάδων';
  static const String teamsSection = 'Ομάδες';
  static const String addTeam = 'Προσθήκη Ομάδας';
  static const String teamNameHint = 'Όνομα ομάδας';
  static const String defaultTeamPrefix = 'Ομάδα';
  static const String minTeamsError = 'Απαιτούνται τουλάχιστον 2 ομάδες.';
  static const String maxTeamsError = 'Μέγιστος αριθμός ομάδων: 8.';
  static const String duplicateTeamNameError =
      'Τα ονόματα των ομάδων πρέπει να είναι μοναδικά.';
  static const String emptyTeamNameError =
      'Το όνομα ομάδας δεν μπορεί να είναι κενό.';
  static const String roundDuration = 'Διάρκεια Γύρου';
  static const String customDuration = 'Προσαρμοσμένος Χρόνος';
  static const String seconds = 'δευτ.';
  static const String minutes = 'λεπτά';
  static const String difficultySelection = 'Επιλογή Δυσκολίας';
  static const String selectAtLeastOneDifficulty =
      'Επιλέξτε τουλάχιστον μία δυσκολία.';
  static const String roundsTitle = 'Αριθμός Γύρων';
  static const String roundsOption3 = '3 γύροι';
  static const String roundsOption5 = '5 γύροι';
  static const String roundsOption10 = '10 γύροι';
  static const String roundsCustom = 'Προσαρμοσμένο';
  static const String roundsUnit = 'γύροι';
  static const String invalidRoundsError =
      'Ο αριθμός γύρων πρέπει να είναι θετικός ακέραιος (τουλάχιστον 1).';
  static const String startGame = 'Έναρξη Παιχνιδιού';
  static const String startRound = 'Έναρξη Γύρου';
  static const String preGameInstruction =
      'Βοηθήστε τους συμπαίκτες σας να βρουν όσες περισσότερες φράσεις μπορούν στον διαθέσιμο χρόνο!';

  // Game Screen
  static const String activeTeamPrefix = 'Σειρά έχει η:';
  static const String round = 'Γύρος';
  static const String roundOf = 'από';
  static const String correct = 'Σωστό';
  static const String pass = 'Πάσο';
  static const String nextPhrase = 'Επόμενη Φράση';
  static const String pause = 'Παύση';
  static const String resume = 'Συνέχεια';
  static const String restart = 'Επανεκκίνηση';
  static const String exitGame = 'Έξοδος';
  static const String exitConfirmationTitle = 'Έξοδος από το παιχνίδι;';
  static const String exitConfirmationContent =
      'Η τρέχουσα πρόοδος του παιχνιδιού θα χαθεί. Θέλετε σίγουρα να επιστρέψετε στην αρχική;';
  static const String earlyEndConfirmationTitle = 'Τέλος παιχνιδιού;';
  static const String earlyEndConfirmationContent =
      'Είστε σίγουροι ότι θέλετε να ολοκληρώσετε το παιχνίδι πρόωρα; Το σκορ θα διατηρηθεί.';
  static const String earlyEndAction = 'Τερματισμός';
  static const String timeUp = 'Τέλος Χρόνου!';
  static const String nextTurn = 'Επόμενη Ομάδα';
  static const String scoreLabel = 'Βαθμοί:';
  static const String currentScore = 'Σκορ';
  static const String freePlayModeTitle = 'Ελεύθερο Παιχνίδι';
  static const String freePlayTimeUpTitle = 'Ο χρόνος τελείωσε!';
  static const String freePlayTimeUpSubtitle = 'Η προσπάθεια ολοκληρώθηκε!';
  static const String endFreePlayAction = 'Τέλος παιχνιδιού';

  // Streak System
  static const String streakBonus = 'Μπόνους σερί';
  static const String streakBonusDescription =
      'Κερδίστε επιπλέον πόντους για συνεχόμενες σωστές φράσεις.';
  static const String streakBonusAwarded = 'μπόνους σερί';

  // Standings & Scoreboard
  static const String standingsTitle = 'Βαθμολογία';
  static const String leader = 'Προηγείται:';
  static const String tie = 'Ισοπαλία!';
  static const String nextRound = 'Επόμενος Γύρος';
  static const String finishGame = 'Τέλος Παιχνιδιού';
  static const String finalResults = 'Τελικά Αποτελέσματα';
  static const String winnerIs = 'Νικήτρια είναι η:';
  static const String playAgain = 'Νέο Παιχνίδι';
  static const String home = 'Αρχική';

  // Settings Screen
  static const String settingsTitle = 'Ρυθμίσεις';
  static const String audioAndHaptics = 'Ήχοι & Δόνηση';
  static const String soundEffects = 'Ηχητικά Εφέ';
  static const String soundEffectsSubtitle =
      'Ήχοι χρονομέτρου, σωστού και λήξης';
  static const String vibration = 'Δόνηση';
  static const String vibrationSubtitle = 'Απτική ανάδραση κατά το παιχνίδι';
  static const String appearance = 'Εμφάνιση';
  static const String themeMode = 'Θέμα';
  static const String themeSystem = 'Σύστημα';
  static const String themeLight = 'Φωτεινό';
  static const String themeDark = 'Σκοτεινό';
  static const String defaultTimerSetting = 'Προεπιλεγμένος Χρόνος Γύρου';
  static const String resetSettings = 'Επαναφορά Ρυθμίσεων';
  static const String resetSettingsConfirm =
      'Θέλετε να επαναφέρετε όλες τις ρυθμίσεις στις αρχικές τους τιμές;';
  static const String resetSuccess = 'Οι ρυθμίσεις επαναφέρθηκαν!';
  static const String about = 'Σχετικά με την εφαρμογή';
  static const String appVersion = 'Έκδοση 1.0.0';
  static const String phrasesTotalLabel =
      '100.000 Πρωτότυπες Ελληνικές Φράσεις';

  // Accessibility labels
  static const String timerSemantic = 'Υπολειπόμενος χρόνος';
  static const String correctButtonSemantic =
      'Καταχώριση σωστής απάντησης (+1 πόντος)';
  static const String passButtonSemantic =
      'Πάσο στην επόμενη φράση (χωρίς πόντο)';
  static const String pauseButtonSemantic = 'Παύση χρονομέτρου';
  static const String resumeButtonSemantic = 'Συνέχιση χρονομέτρου';
  static const String phraseSemantic = 'Φράση παντομίμας προς υπόδυση';
  static const String difficultySemantic = 'Βαθμός δυσκολίας φράσης';
}
