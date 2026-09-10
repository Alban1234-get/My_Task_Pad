import 'dart:async';
import 'package:flutter/foundation.dart';

/// Service réutilisable encapsulant la logique d'autosave par debounce.
class AutosaveService {
  final Duration debounceDuration;
  Timer? _debounceTimer;

  AutosaveService({this.debounceDuration = const Duration(milliseconds: 700)});

  /// Planifie une sauvegarde après un délai d'inactivité (debounce).
  void schedule(VoidCallback onSave) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, onSave);
  }

  /// Exécute la sauvegarde immédiatement en annulant tout timer en cours.
  void saveNow(VoidCallback onSave) {
    _debounceTimer?.cancel();
    onSave();
  }

  /// Annule le timer sans exécuter la sauvegarde.
  void cancel() {
    _debounceTimer?.cancel();
  }

  /// Libère les ressources du service.
  void dispose() {
    _debounceTimer?.cancel();
  }
}

