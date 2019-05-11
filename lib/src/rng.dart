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

import 'package:charcode/ascii.dart';
import 'package:rng/src/constants.dart';

const int _kMin64BitInt = 0x8000000000000000;
const int _kMax64BitInt = 0x7FFFFFFFFFFFFFFF;

 const int _kMinValueRandomInt = 1;
 const int _kMaxValueRandomIntExclusive = 1 << 32;
 const int _kMaxValueRandomIntInclusive =
    _kMaxValueRandomIntExclusive - 1;
 const int _kMinValueRandom31BitIntExclusive = -0x40000000;
 const int _kMinValueRandom31BitIntInclusive =
    _kMinValueRandom31BitIntExclusive + 1;
 const int _kMaxValueRandom31BitIntExclusive = 0x40000000;
 const int _kMaxValueRandom31BitIntInclusive =
    _kMaxValueRandom31BitIntExclusive - 1;
const int _kMaxValueRandom30BitInt = 0x3FFFFFFF;


/// Random Number Generator with useful utilities.
///
/// This package extends the [Random] number generator provided by
/// the Dart _core_ library.
//TODO: document
class RNG {
  /// True if using [Random.secure].
  final bool isSecure;
  /// The default minimum [String] length returned.
  final int defaultMinStringLength;
  /// The default maximum [String] length returned.
  final int defaultMaxStringLength;
  /// The default minimum [List] length returned.
  final int defaultMinListLength;
  /// The default maximum [List] length returned.
  final int defaultMaxListLength;

  /// The initial [seed]. If _null_ no [seed] was provided.
  final int seed;

  /// The [Random] number generator being used.
  final Random generator;

  /// Creates a Random Number Generator ([RNG]) using Dart's [Random].
  factory RNG([int seed]) => RNG.withDefaults(isSecure: false, seed: seed);

  /// Creates a **_secure_** Random Number Generator ([RNG]) using Dart's
  /// [Random.secure].
  factory RNG.secure() => RNG.withDefaults(isSecure: true);

  /// Creates a Random Number Generator ([RNG]) with the specified default
  /// values.
  RNG.withDefaults({
    this.isSecure = false,
    this.seed,
    this.defaultMinStringLength = 4,
    this.defaultMaxStringLength = 1024,
    this.defaultMinListLength = 1,
    this.defaultMaxListLength = 256,
  }) : generator = isSecure ? Random.secure() : Random(seed);

  /// Returns a random boolean ([bool]).
  bool get nextBool => generator.nextBool();

  /// Returns a random 8-bit signed integer ([int]).
  int get nextInt8 => _nextInt32(kInt8MinValue, kInt8MaxValue);

  /// Returns a random 16-bit signed integer ([int]).
  int get nextInt16 => _nextInt32(kInt16MinValue, kInt16MaxValue);

  /// Returns a random 32-bit signed integer ([int]).
  int get nextInt32 => _nextInt32(kInt32MinValue, kInt32MaxValue);

  /// Returns a random 64-bit signed integer ([int]).
  int get nextInt64 => _nextSMUint();

  /// Returns a random 7-bit unsigned integer ([int]), i.e. an ASCII code unit.
  int get nextUint7 => _nextUint32(0, 127);

  /// Returns a random 8-bit unsigned integer ([int]).
  int get nextUint8 => _nextUint32(0, kUint8MaxValue);

  /// Returns a random 16-bit unsigned integer ([int]).
  int get nextUint16 => _nextUint32(0, kUint16MaxValue);

  /// Returns a random 32-bit unsigned integer ([int]).
  int get nextUint32 => _nextUint32(0, kUint32MaxValue);

  /// Returns a random 64-bit unsigned integer ([int]).
  int get nextUint64 => _nextSMUint();

  /// Returns a [double] between 0 and 1.
  double get nextDouble => generator.nextDouble();


  /// Returns a [double] between the most-negative and most-positive 32-bit
  /// signed integers.
  double get nextFloat => nextDouble * nextInt32;

  static final Float32List _float32 = Float32List(1);

  /// Returns a double in the range of an IEEE 32-bit floating point number.
  double get nextFloat32 {
    final n = nextDouble;
    _float32[0] = n;
    // ignore: only_throw_errors
    if (_float32[0].isNaN) throw 'NaN: ${_float32[0]}';
    return _float32[0];
  }

  /// Synonym for [nextDouble].
  double get nextFloat64 => nextDouble;

  /// Returns an ASCII character (code point), i.e. in range 0 - 127 inclusive.
  int get nextAscii => nextUint7;

  /// Returns a visible (printing) ASCII character (code point),
  /// i.e. in range 32 - 126 inclusive.
  int get nextAsciiVChar => _nextUint32($space, $tilde);

  /// Returns an ASCII digit character (code point) between 0 and 9.
  int get nextAsciiDigit => _nextUint32($0, $9);

  /// Returns an ASCII alphabetic (A-Z, a-z) character (code point) or
  /// the underscore character (_).
  int get nextAsciiWordChar => _nextAsciiWordChar();

  int _nextAsciiWordChar() {
    final c = _nextUint32($0, $z);
    if (isWordChar(c)) return c;
    return _nextAsciiWordChar();
  }

  /// Returns a Utf8 code point, i.e. between 32 and 255.
  int get nextUtf8 => _nextUint32(32, 255);

  /// Returns a [String] containing a single ASCII digit character
  /// (code point) between 0 and 9.
  String get nextDigit => String.fromCharCode(nextAsciiDigit);

  //int get nextMicrosecond => _nextMicrosecond();

  //Urgent: finish after all test working
  int _nextMicrosecond() {
    final us = _nextSMInt();
//    if (isValidDateTimeMicroseconds(us)) return us;
//    return _nextMicrosecond();
    return us;
  }

  /// Returns a random String with sign + 1 - 11 digits
  String nextIntString([int minLength = 1, int maxLength = 12]) {
    RangeError.checkValidRange(1, minLength, maxLength);
    RangeError.checkValidRange(minLength, maxLength, 12);
    final len = _getLength(minLength, maxLength);
    if (len == 1) return nextDigit;
    final sb = StringBuffer();

    final sign = nextBool;
    if (sign == true) {
      sb.writeCharCode($minus);
    } else {
      sb.writeCharCode($plus);
    }

    sb.writeCharCode(nextAsciiDigit);
    for (var i = sb.length; i < len; i++) sb.writeCharCode(nextAsciiDigit);
    final s = sb.toString();
    RangeError.checkValidRange(1, s.length, 16);
    return s;
  }

  /// Returns a [String] containing ASCII word characters, i.e.
  /// either alphabetic (A-Z, a-z) or the underscore (_) characters.
  String nextAsciiWord([int minLength = 1, int maxLength = 16]) {
    final len = _getLength(minLength, maxLength);
    final sb = StringBuffer();
    for (var i = 0; i < len; i++) {
      final c = nextAsciiWordChar;
      // ignore: only_throw_errors
      if (!isWordChar(c)) throw 'Invalid Word Char: $c';
      sb.writeCharCode(c);
    }
    final s = sb.toString();
    return s;
  }

  static bool _always(int c) => true;

  /// Returns an ASCII character (code point). [predicate]
  /// defaults to always _true_.
  int nextAsciiSatisfying([bool predicate(int char) = _always]) {
    final c = nextUint7;
    return (predicate(c)) ? c : nextAsciiSatisfying(predicate);
  }

  /// Returns a 32-bit random number between [min] and [max] inclusive.
  int _nextUint32(int minimum, int maximum) {
    final limit = maximum - minimum;
    assert(limit <= 0xFFFFFFFF);
    return generator.nextInt(limit + 1) + minimum;
  }


  /// Returns a 63-bit integer (DartSMInt) in the range from [min]
  /// to [max] inclusive.
  ///
  /// Note: [min] and [max] can be negative, but [min] must be less than [max].
  int nextInt([int min = _kMin64BitInt, int max = _kMax64BitInt]) {
    RangeError.checkValueInInterval(
        min, _kMin64BitInt, _kMax64BitInt, 'min');
    RangeError.checkValueInInterval(max, min, _kMax64BitInt, 'max');
    var limit = _getLimit(min, max);
    if (limit > _kMax64BitInt) limit = _kMax64BitInt;
    if (limit < 0 || limit > _kMax64BitInt)
      // ignore: only_throw_errors
      throw 'Invalid range error: '
          '$_kMin64BitInt > $max - $min = $limit < $_kMax64BitInt';
    final n = (limit < kUint32MaxValue)
        ? __nextUint32(limit)
        : _nextSMUint().remainder(limit);
    return n + min;
  }

  // Returns a 32-bit unsigned integer in the range from -[limit] to [limit]
  // inclusive. _Note_: 0 <= [limit] <= 0xFFFFFFFF.
  int __nextUint32(int limit) => generator.nextInt(limit + 1);

  // Always returns a positive integer that is less than Int32MaxValue.
  int _getLimit(int min, int max) {
    assert(min >= _kMin64BitInt && max <= _kMax64BitInt && min <= max);
    final limit = max - min;
    return (limit < 0) ? -limit : limit;
  }

  // Returns a 32-bit signed integer in the range from -[limit] to [limit]
  // inclusive. _Note_: 0 <= [limit] <= 0xFFFFFFFF.
  int _nextInt32([int min = kInt32MinValue, int max = kInt32MaxValue]) {
    assert(min != null && max != null);
    final limit = _getLimit32(min, max);
    return generator.nextInt(limit + 1) + min;
  }

  // Always returns a positive integer that is less than Int32MaxValue.
  int _getLimit32(int min, int max) {
    assert(min >= kInt32MinValue);
    assert(max <= kInt32MaxValue);
    var limit = max - min;
    if (limit < 0) limit = -limit;
    if (limit > kUint32MaxValue) limit = kUint32MaxValue;
    return limit;
  }

  // TODO: See _nextSMInt issue is same
  /// Returns a 64-bit random unsigned integer _n_, in the range
  /// 0 >= n <= [_kMax64BitInt]
  int _nextSMUint() {
    final upper = generator.nextInt(_kMaxValueRandom30BitInt);
    final lower = generator.nextInt(_kMaxValueRandomIntExclusive);
    final n = (upper << 32) | lower;
    assert(n >= 0 && n <= _kMax64BitInt);
    return n;
  }

  // TODO:
  // This was designed for V1 with only supported 63-bit [int]s.
  // Currently the V2 DartVM supports 64-but [int]s, and this should
  // change; but JavaScript only supports 54-bit [int]s.
  // However, it is a breaking change; so, Major version must increase by 1.
  /// Returns a 63-bit random signed integer _n_, in the range
  /// [kDartMinValueSMInt >= n <= [kDartMaxValueSMInt]
  int _nextSMInt() {
    final upper = generator.nextInt(_kMaxValueRandom30BitInt);
    final lower = generator.nextInt(_kMaxValueRandomIntExclusive);
    var n = (upper << 32) | lower;
    n = (generator.nextBool()) ? n : -n;
    assert(n >= _kMin64BitInt && n <= _kMax64BitInt,
        '$_kMin64BitInt <= $n ${n.toRadixString(16)} <= $_kMax64BitInt');
    return n;
  }

  // TODO: See _nextSMInt issue is same
  /// Returns a 63-bit random number between [min] and [max] inclusive,
  /// Where [min] >= 0, and [max] >= min && [max] <= 0xFFFFFFFF.
  int nextUint([int min = 0, int max = _kMax64BitInt]) {
    RangeError.checkValueInInterval(min, 0, _kMax64BitInt, 'min');
    RangeError.checkValueInInterval(max, min, _kMax64BitInt, 'max');
    var limit = max - min;
    if (limit > _kMax64BitInt) limit = _kMax64BitInt;
    if (limit < 0 || limit > _kMax64BitInt)
      // ignore: only_throw_errors
      throw 'Invalid range error: 0 > $max - $min = $limit < 0xFFFFFFFF';
    return (limit < kUint32MaxValue)
        ? generator.nextInt(limit + 1) + min
        : _nextSMUint().remainder(limit + 1);
  }

  /// Returns [String] containing visible ASCII code points, i.e. between
  /// [$space](32) and [$del] - 1(126). If [length] is specified, the
  /// returned [String] will have that [length]; otherwise, it will have
  /// a random length, between 4 and 1024 inclusive.
  Uint8List asciiString([int length]) {
    length ??= nextUint(defaultMinStringLength, 1024);
    RangeError.checkValueInInterval(length, 0, 4096, 'length');
    final v = Uint8List(length);
    for (var i = 0; i < length; i++) v[i] = nextAsciiVChar;
    return v;
  }

  /// Returns [String] of [length] containing UTF-8 code units in the range
  /// from 0 to 255. If [length] is specified, the returned [String] will
  /// have that [length]; otherwise, it will have a random length, between 4
  /// and 1024 inclusive. _Note_: While the returned [String] will contain
  /// UTF-8 code units, they will not necessarily be valid code points.
  Uint8List utf8String([int length]) {
    length ??= nextUint(defaultMinStringLength, 1024);
    RangeError.checkValueInInterval(length, 0, 4096, 'length');
    final v = Uint8List(length);
    for (var i = 0; i < length; i++) v[i] = nextUint8;
    return v;
  }

  /// Returns a random a length between [minLength] and [maxLength] inclusive.
  /// [minLength] must be greater than or equal to 0, and [maxLength] must
  /// be less than or equal to 2^31-1, i.e. the maximum 32-bit signed positive
  /// integer.
  int getLength([int minLength, int maxLength]) =>
      _getLength(minLength, maxLength);

  int _getLength([int minLength, int maxLength]) {
    if (maxLength == 0) return 0;
    final min = (minLength == null) ? defaultMinListLength : minLength;
    final max = (maxLength == null) ? defaultMaxListLength : maxLength;
    RangeError.checkValidRange(0, min, kInt32MaxValue, 'minLength');
    RangeError.checkValidRange(min, max, kInt32MaxValue, 'maxLength');
    return nextUint(minLength, maxLength);
  }

  /// Returns a random [List<int>] with a length between [minLength] and
  /// [maxLength] inclusive. The [List] will contain integers in the range
  /// [minValue] to [maxValue] inclusive. [minValue] and [maxValue] must be
  /// valid 32-bit integers. [minLength] defaults to 1, and [maxLength]
  /// defaults to 256.
  List<int> intList(int minValue, int maxValue,
      [int minLength, int maxLength]) {
    RangeError.checkValueInInterval(
        minValue, kInt32MinValue, kInt32MaxValue, 'minValue');
    RangeError.checkValueInInterval(
        maxValue, minValue, kInt32MaxValue, 'maxValue');
    final len = _getLength(minLength, maxLength);
    final vList = List<int>(len);
    for (var i = 0; i < len; i++) vList[i] = nextInt(minValue, maxValue);
    return vList;
  }

  /// Returns a [List<ByteData>].
  ByteData byteDataList(int minValue, int maxValue,
      [int minLength, int maxLength]) {
    RangeError.checkValueInInterval(
        minValue, kUint8MinValue, kUint8MaxValue, 'minValue');
    RangeError.checkValueInInterval(
        maxValue, minValue, kUint32MaxValue, 'maxValue');
    final len = _getLength(minLength, maxLength);
    final vList = ByteData(len);
    for (var i = 0; i < len; i++)
      vList.setUint8(i, nextInt(minValue, maxValue));
    return vList;
  }

  /// Returns a random [List<int>] with a length between [minLength] and
  /// [maxLength] inclusive. The [List] will contain 8-bit signed integers.
  Int8List int8List([int minLength, int maxLength]) {
    final length = _getLength(minLength, maxLength);
    final v = Int8List(length);
    for (var i = 0; i < length; i++) v[i] = nextInt8;
    return v;
  }

  /// Returns a random [Int16List] with a length between [minLength] and
  /// [maxLength] inclusive. The [List] will contain 16-bit signed integers.
  Int16List int16List([int minLength, int maxLength]) {
    final length = _getLength(minLength, maxLength);
    final v = Int16List(length);
    for (var i = 0; i < length; i++) v[i] = nextInt16;
    return v;
  }

  /// Returns a random [Int32List] with a length between [minLength] and
  /// [maxLength] inclusive. The [List] will contain 32-bit signed integers.
  Int32List int32List([int minLength, int maxLength]) {
    final length = _getLength(minLength, maxLength);
    final v = Int32List(length);
    for (var i = 0; i < length; i++) v[i] = nextInt32;
    return v;
  }

  /// Returns a random [Int64List] with a length between [minLength] and
  /// [maxLength] inclusive. The [List] will contain 64-bit signed integers.
  Int64List int64List([int minLength, int maxLength]) {
    final length = _getLength(minLength, maxLength);
    final v = Int64List(length);
    for (var i = 0; i < length; i++) v[i] = nextInt64;
    return v;
  }

  /// Returns a random [Uint8List] with a length between [minLength] and
  /// [maxLength] inclusive. The [List] will contain 8-bit unsigned integers.
  Uint8List uint8List([int minLength, int maxLength]) {
    final length = _getLength(minLength, maxLength);
    final v = Uint8List(length);
    for (var i = 0; i < length; i++) v[i] = nextUint8;
    return v;
  }

  /// Returns a random [Uint16List] with a length between [minLength] and
  /// [maxLength] inclusive. The [List] will contain 16-bit unsigned integers.
  Uint16List uint16List([int minLength, int maxLength]) {
    final length = _getLength(minLength, maxLength);
    final v = Uint16List(length);
    for (var i = 0; i < length; i++) v[i] = nextUint16;
    return v;
  }

  /// Returns a random [Uint32List] with a length between [minLength] and
  /// [maxLength] inclusive. The [List] will contain 32-bit unsigned integers.
  Uint32List uint32List([int minLength, int maxLength]) {
    final length = _getLength(minLength, maxLength);
    final v = Uint32List(length);
    for (var i = 0; i < length; i++) v[i] = nextUint32;
    return v;
  }

  /// Returns a random [Uint64List] with a length between [minLength] and
  /// [maxLength] inclusive. The [List] will contain 64-bit unsigned integers.
  Uint64List uint64List([int minLength, int maxLength]) {
    final length = _getLength(minLength, maxLength);
    final v = Uint64List(length);
    for (var i = 0; i < length; i++) v[i] = nextUint64;
    return v;
  }

  /// Returns a random [List<double>] with a length between [minLength] and
  /// [maxLength] inclusive.
  List<double> listOfDouble([int minLength = 1, int maxLength = 1000]) {
    final len = _getLength(minLength, maxLength);
    final vList = List<double>(len);
    for (var i = 0; i < len; i++) vList[i] = nextDouble;
    return vList;
  }

  /// Returns a random [List<double>] with a length between [minLength] and
  /// [maxLength] inclusive.
  List<double> listOfFloat32([int minLength, int maxLength]) {
    final len = _getLength(minLength, maxLength);
    final vList = List<double>(len);
    for (var i = 0; i < len; i++) vList[i] = nextFloat32;
    return vList;
  }

  /// Returns a random [Float32List] with a length between [minLength] and
  /// [maxLength] inclusive. The [List] will contain 32-bit floating point
  /// numbers.
  Float32List float32List([int minLength, int maxLength]) {
    final length = _getLength(minLength, maxLength);
    final v = Float32List(length);
    for (var i = 0; i < length; i++) v[i] = nextFloat32;
    return v;
  }

  /// Returns a random [Float64List] with a length between [minLength] and
  /// [maxLength] inclusive. The [List] will contain 64-bit floating point
  /// numbers.
  Float64List float64List([int minLength, int maxLength]) {
    final length = _getLength(minLength, maxLength);
    final v = Float64List(length);
    for (var i = 0; i < length; i++) v[i] = nextFloat64;
    return v;
  }
}

/// Returns _true_ if [c] is an regex \w character, i.e. alphanumeric or '_'.
bool isWordChar(int c) =>
    (c >= $a) && (c <= $z) || (c >= $A) && (c <= $Z) || c == $underscore;
