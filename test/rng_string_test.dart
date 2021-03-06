//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'package:charcode/ascii.dart';
import 'package:rng/rng.dart';
import 'package:test/test.dart';

void main() {
  group('RNG Strings test', () {
    final rng = RNG(0);

    test('nextDigit test', () {
      final count = rng.getLength(10, 100);
      for (var i = 0; i < count; i++) {
        final c = rng.nextDigit;
        final n = c.codeUnitAt(0);
        expect(n >= $0 + 0 && n <= $0 + 9, true);
      }
    });

    test('nextIntString test', () {
      final count = rng.getLength(10, 100);
      for (var i = 0; i < count; i++) {
        final len = rng.getLength(1, 12);
        final s = rng.nextIntString(len, len);
        expect(s.isNotEmpty && s.length <= 16, true);
        expect(int.parse(s) is int, true);
      }
    });

    var minWordLength = 1;
    var maxWordLength = 16;

    test('nextAsciiWord test', () {
      final count = rng.getLength(10, 100);
      for (var i = 0; i < count; i++) {
        final word = rng.nextAsciiWord(minWordLength, maxWordLength);
        expect(
            word.length >= minWordLength && word.length <= maxWordLength, true);
        final codeUnits = word.codeUnits;
        for (final c in codeUnits) expect(isWordChar(c), true);
      }

      minWordLength = 16;
      maxWordLength = 64;
      for (var i = 0; i < count; i++) {
        final word = rng.nextAsciiWord(minWordLength, maxWordLength);
        expect(
            word.length >= minWordLength && word.length <= maxWordLength, true);
        final codeUnits = word.codeUnits;
        for (final c in codeUnits) expect(isWordChar(c), true);
      }
    });
  });
}
