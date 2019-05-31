//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'dart:math';
import 'dart:typed_data';

import 'package:charcode/charcode.dart';
import 'package:rng/src/rng.dart';

/// Random Number Generator with useful utilities.
///
/// This package extends the [Random] number generator provided by
/// the Dart _core_ library.
//TODO: document
class DicomRNG extends RNG {
  /// Creates a Random Number Generator ([DicomRNG]) using Dart's [Random].
  factory DicomRNG([int seed]) =>
      DicomRNG.withDefaults(isSecure: false, seed: seed);

  /// Creates a **_secure_** Random Number Generator ([DicomRNG]) using Dart's
  /// [Random.secure].
  factory DicomRNG.secure() => DicomRNG.withDefaults(isSecure: true);

  /// Creates a Random Number Generator ([DicomRNG]) with the specified default
  /// values.
  DicomRNG.withDefaults({
    bool isSecure = false,
    int seed,
    int defaultMinStringLength = 4,
    int defaultMaxStringLength = 1024,
    int defaultMinListLength = 1,
    int defaultMaxListLength = 256,
  }) : super.withDefaults(
            isSecure: isSecure,
            seed: seed,
            defaultMinListLength: defaultMinListLength,
            defaultMaxListLength: defaultMaxListLength,
            defaultMinStringLength: defaultMinStringLength,
            defaultMaxStringLength: defaultMaxStringLength);

  /// Returns a visible (printing) ASCII character (code point),
  /// except for [$backslash] ('\').
  int get nextAsciiDicomChar => _nextAsciiDicomChar();

  int _nextAsciiDicomChar() {
    final c = _nextUint32($space, $tilde);
    return (c == $backslash) ? _nextAsciiDicomChar : c;
  }

  /// Returns a visible (printing) Latin character (code point),
  /// except for [$backslash] ('\').
  int get nextLatinDicomChar => _nextLatinDicomChar();

  int _nextLatinDicomChar() {
    final c = nextLatinChar;
    return (c == $backslash) ? _nextLatinDicomChar() : c;
  }

  /// Returns an ASCII alphabetic (A-Z, a-z) character (code point) or
  /// the underscore character (_).
  int get nextDicomKeywordChar => _nextDicomKeywordChar();

  int _nextDicomKeywordChar() {
    final c = _nextUint32($0, $z);
    return (_isDicomKeywordChar(c)) ? c : _nextDicomKeywordChar();
  }

  /// Returns a [String] containing ASCII word characters, i.e.
  /// either alphabetic (A-Z, a-z) or the underscore (_) characters.
  String nextDicomKeyword([int minLength = 1, int maxLength = 16]) {
    final len = getLength(minLength, maxLength);
    final list = Uint8List(len);
    for (var i = 0; i < len; i++) list[i] = _nextDicomKeywordChar();
    return String.fromCharCodes(list);
  }

  /// Returns _true_ if [c] is an regex \w character,
  /// i.e. alphanumeric or '_'.
  bool isDicomKeywordChar(int c) => _isDicomKeywordChar(c);

  /// Returns a 32-bit random number between [min] and [max] inclusive.
  int _nextUint32(int min, int max) {
    final limit = (max - min) + 1;
    assert(limit <= 1 << 32);
    return generator.nextInt(limit) + min;
  }

  bool _isDicomKeywordChar(int c) =>
      (c >= $a) && (c <= $z) || (c >= $A) && (c <= $Z) || c == $underscore;
}
