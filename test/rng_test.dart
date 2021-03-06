//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
//
import 'dart:typed_data';

import 'package:rng/rng.dart';
import 'package:test/test.dart';

void main() {
  group('getLength tests of RNG', () {
    final rng = RNG(0);
    const count = 10;
    const minMin = 3;
    const maxMin = 31;
    const minMax = 32;
    const maxMax = 255;

    test('getLength test', () {
      for (var i = 0; i < count; i++) {
        final l0 = rng.getLength(minMin, maxMin);
        expect(l0, inInclusiveRange(minMin, maxMin));

        final l1 = rng.getLength(minMax, maxMax);
        expect(l1, inInclusiveRange(minMax, maxMax));

        final l2 = rng.getLength(minMin, maxMax);
        expect(l2, inInclusiveRange(minMin, maxMax));
      }
    });

    test('IntList Test', () {
      for (var i = 0; i < count; i++) {
        final list = rng.intList(-20, 60, minMin, maxMin);
        expect(list is List<int>, true);
        expect(list.length, inInclusiveRange(minMin, maxMin));
        for (final i in list) expect(i, inInclusiveRange(-20, 60));
      }
    });

    test('IntList Test values', () {
      for (var i = 1; i < count; i++) {
        final list = rng.intList(i, i + 1, minMin, maxMin);
        expect(list is List<int>, true);
        expect(list.length, inInclusiveRange(minMin, maxMin));
        for (final i in list) expect(i, inInclusiveRange(i, i + 1));
      }
    });

    test('IntList Test length', () {
      for (var i = 1; i < count; i++) {
        final minMin = i, minMax = i + 1;
        final list = rng.intList(i, i + 1, minMin, minMax);
        expect(list is List<int>, true);
        expect(list.length, inInclusiveRange(minMin, minMax));
        for (final i in list) expect(i, inInclusiveRange(i, i + 1));
      }
    });
  });

  group('Integer tests of Random Number Generator(RNG)', () {
    final rng = RNG(0);
    const minMin = 3;
    const maxMin = 31;
    const minMax = 32;
    const maxMax = 255;
    final minLength = rng.nextUint(minMin, maxMin);
    final maxLength =
        rng.nextUint(minLength, minLength + rng.nextUint(minMax, maxMax));

    //TODO: test range of values
    test('IntList Test', () {
      final list = rng.intList(-20, 60, minLength, maxLength);
      expect(list is List<int>, true);
      expect(list.length, inInclusiveRange(minLength, maxLength));
      for (final i in list) expect(i, inInclusiveRange(-20, 60));
    });

    test('Int8List Test', () {
      final list = rng.int8List(minLength, maxLength);
      expect(list.length, inInclusiveRange(minLength, maxLength));
      expect(list is Int8List, true);
    });

    test('Int16List Test', () {
      final list = rng.int16List(minLength, maxLength);
      expect(list.length, inInclusiveRange(minLength, maxLength));
      expect(list is Int16List, true);
    });

    test('Int32List Test', () {
      final list = rng.int32List(minLength, maxLength);
      expect(list.length, inInclusiveRange(minLength, maxLength));
      expect(list is Int32List, true);
    });

    test('Int64List Test', () {
      final list = rng.int64List(minLength, maxLength);
      expect(list.length, inInclusiveRange(minLength, maxLength));
      expect(list is Int64List, true);
    });

    test('Uint8List Test', () {
      final list = rng.uint8List(minLength, maxLength);
      expect(list.length, inInclusiveRange(minLength, maxLength));
      expect(list is Uint8List, true);
    });

    test('Uint16List Test', () {
      final list = rng.uint16List(minLength, maxLength);
      expect(list.length, inInclusiveRange(minLength, maxLength));
      expect(list is Uint16List, true);
    });

    test('Uint32List Test', () {
      final list = rng.uint32List(minLength, maxLength);
      expect(list.length, inInclusiveRange(minLength, maxLength));
      expect(list is Uint32List, true);
    });

    test('Uint64List Test', () {
      final list = rng.uint64List(minLength, maxLength);
      expect(list.length, inInclusiveRange(minLength, maxLength));
      expect(list is Uint64List, true);
    });
  });

  group('Random floating Point numbers tests of ', () {
    final rng = RNG(0);
    const count = 10;

    test('nextDouble Test', () {
      for (var i = 0; i < count; i++) {
        final nd = rng.nextDouble;
        expect(nd is double, true);
        expect(nd >= 0 || nd <= 1, true);
      }
    });

    test('nextFloat Test', () {
      for (var i = 0; i < count; i++) {
        final nf = rng.nextFloat;
        expect(nf is double, true);
        expect(nf.abs() > 1, true);
      }
    });

    test('nextFloat32 Test', () {
      final floatBox = Float32List(1);

      for (var i = 0; i < count; i++) {
        final nf32 = rng.nextFloat32;
        floatBox[0] = nf32;
        expect(nf32 is double, true);
        expect(floatBox[0] is double, true);
        expect(nf32 == floatBox[0], true);
        expect(nf32 >= 0 || nf32 <= 1, true);
      }
    });
  });

  group('Random Floating point lists test', () {
    final rng = RNG(0);
    const count = 10;

    test('listOfDouble Test', () {
      for (var i = 0; i < count; i++) {
        final list = rng.listOfDouble(1, 32);
        expect(list is List<double>, true);
        expect(list.length, inInclusiveRange(1, 32));
      }
    });

    test('List<Float32> Test', () {
      for (var i = 0; i < count; i++) {
        final list0 = rng.listOfFloat32(1, 32);
        expect(list0 is List<double>, true);
        expect(list0.length, inInclusiveRange(1, 32));

        final list1 = Float32List.fromList(list0);
        expect(list0.length == list1.length, true);
        for (var i = 0; i < list0.length; i++) {
          expect(list0[i] == list1[i], true);
        }
      }
    });

    test('Float32List Test', () {
      for (var i = 0; i < count; i++) {
        final list = rng.float32List(1, 32);
        expect(list is Float32List, true);
        expect(list.length, inInclusiveRange(1, 32));
      }
    });

    test('Float64List Test', () {
      for (var i = 0; i < count; i++) {
        final list = rng.float64List(1, 32);
        expect(list is Float64List, true);
        expect(list.length, inInclusiveRange(1, 32));
      }
    });
  });
}
