// The default Flutter counter template used to live here. It referenced a
// `MyApp` class that does not exist in this project, so the whole test suite
// failed to compile. A smoke test of the real root widget needs a live
// Firebase app, so this covers the theme instead — pure, and enough to keep
// the suite compiling.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:house_manager/main.dart';

void main() {
  group('AppTheme', () {
    test('exposes a light and a dark theme', () {
      expect(AppTheme.lightTheme.brightness, Brightness.light);
      expect(AppTheme.darkTheme.brightness, Brightness.dark);
    });

    test('uses Material 3', () {
      expect(AppTheme.lightTheme.useMaterial3, isTrue);
      expect(AppTheme.darkTheme.useMaterial3, isTrue);
    });
  });
}
