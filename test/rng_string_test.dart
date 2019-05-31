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
  const min = 0;
  const max = 100;
  final rng = DicomRNG(0);

  group('RNG Strings test', () {
    test('nextDigit test', () {
      final count = rng.getLength(min, max);
      for (var i = 0; i < count; i++) {
        final c = rng.nextDigit;
        final n = c.codeUnitAt(0);
        expect(n >= $0 + 0 && n <= $0 + 9, isTrue);
      }
    });

    test('nextIntString test', () {
      final count = rng.getLength(min, max);
      for (var i = 0; i < count; i++) {
        final len = rng.getLength(1, 12);
        final s = rng.nextIntString(len, len);
        expect(s.isNotEmpty && s.length <= 16, isTrue);
        expect(int.parse(s) is int, isTrue);
      }
    });

    var minWordLength = 1;
    var maxWordLength = 16;

    test('nextDicomKeyword test', () {
      final count = rng.getLength(min, max);
      for (var i = 0; i < count; i++) {
        final word = rng.nextDicomKeyword(minWordLength, maxWordLength);
        expect(word.length >= minWordLength && word.length <= maxWordLength,
            isTrue);
        final codeUnits = word.codeUnits;
        for (final c in codeUnits) expect(rng.isDicomKeywordChar(c), isTrue);
      }

      minWordLength = 16;
      maxWordLength = 64;
      for (var i = 0; i < count; i++) {
        final word = rng.nextDicomKeyword(minWordLength, maxWordLength);
        expect(word.length >= minWordLength && word.length <= maxWordLength,
            isTrue);
        final codeUnits = word.codeUnits;
        for (final c in codeUnits) expect(rng.isDicomKeywordChar(c), isTrue);
      }
    });
  });
}
