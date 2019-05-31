//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'dart:convert' as cvt;
import 'dart:math';
import 'dart:typed_data';

import 'package:charcode/charcode.dart';
import 'package:rng/src/constants.dart';

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

  /// Returns a 64-bit integer in the range from [min] to [max] inclusive.
  ///
  /// Note: [min] and [max] can be negative, but [min] must be less than [max].
  int nextInt([int min = kInt64Min, int max = kInt64Max]) => _nextInt(min, max);

  /// Returns a random [List<int>] with a length between [minLength] and
  /// [maxLength] inclusive. The [List] will contain integers in the range
  /// [min] to [max] inclusive. [min] and [max] must be
  /// valid 32-bit integers. [minLength] defaults to 1, and [maxLength]
  /// defaults to 256.
  List<int> intList(int min, int max, [int minLength, int maxLength]) {
    final len = _getLength(minLength, maxLength);
    final vList = List<int>(len);
    for (var i = 0; i < len; i++) vList[i] = _nextInt(min, max);
    return vList;
  }

  /// Returns a 64-bit integer in the range from [min] to [max] inclusive.
  ///
  /// Note: [min] and [max] can be negative, but [min] must be less than [max].
  int _nextInt([int min = kInt64Min, int max = kInt64Max]) {
    RangeError.checkValueInInterval(min, kInt64Min, kInt64Max, 'min');
    RangeError.checkValueInInterval(max, min, kInt64Max, 'max');
    final limit = _getLimit(min, max);
    final n = (limit < kUint32Max)
        ? generator.nextInt(limit)
        : _nextUint64().remainder(limit);
    return n + min;
  }

  /// Returns a random 8-bit signed integer ([int]).
  int get nextInt8 => _nextInt32(kInt8Min, kInt8Max);

  /// Returns a random [List<int>] with a length between [minLength] and
  /// [maxLength] inclusive. The [List] will contain 8-bit signed integers.
  Int8List int8List([int minLength, int maxLength]) {
    final length = _getLength(minLength, maxLength);
    final v = Int8List(length);
    for (var i = 0; i < length; i++) v[i] = _nextInt32(kInt8Min, kInt8Max);
    return v;
  }

  /// Returns a random 16-bit signed integer ([int]).
  int get nextInt16 => _nextInt32(kInt16Min, kInt16Max);

  /// Returns a random [Int16List] with a length between [minLength] and
  /// [maxLength] inclusive. The [List] will contain 16-bit signed integers.
  Int16List int16List([int minLength, int maxLength]) {
    final length = _getLength(minLength, maxLength);
    final v = Int16List(length);
    for (var i = 0; i < length; i++) v[i] = _nextInt32(kInt16Min, kInt16Max);
    return v;
  }

  /// Returns a random 32-bit signed integer ([int]).
  int get nextInt32 => _nextInt32(kInt32Min, kInt32Max);

  /// Returns a random [Int32List] with a length between [minLength] and
  /// [maxLength] inclusive. The [List] will contain 32-bit signed integers.
  Int32List int32List([int minLength, int maxLength]) {
    final length = _getLength(minLength, maxLength);
    final v = Int32List(length);
    for (var i = 0; i < length; i++) v[i] = _nextInt32(minLength, maxLength);
    return v;
  }

  // Returns a 32-bit signed integer in the range from -[limit] to [limit]
  // inclusive. _Note_: 0 <= [limit] <= 0xFFFFFFFF.
  int _nextInt32([int min = kInt32Min, int max = kInt32Max]) {
    assert(min != null && max != null);
    final limit = _getLimit32(min, max);
    return generator.nextInt(limit + 1) + min;
  }

  /// Returns a random 64-bit signed integer ([int]).
  int get nextInt64 => _nextInt64(kInt64Min, kInt64Max);

  /// Returns a random [Int64List] with a length between [minLength] and
  /// [maxLength] inclusive. The [List] will contain 64-bit signed integers.
  Int64List int64List([int minLength, int maxLength]) {
    final length = _getLength(minLength, maxLength);
    final v = Int64List(length);
    for (var i = 0; i < length; i++) v[i] = _nextInt64(minLength, maxLength);
    return v;
  }

  /// Returns a 64-bit random signed integer _n_, in the range
  /// [kInt64Min >= n <= [kInt64Max].
  int _nextInt64([int min = kInt64Min, int max = kInt64Max]) {
    final upper = generator.nextInt(kUint32Max);
    final lower = generator.nextInt(kUint32Max);
    final n = (upper << 32) | lower;
    return (generator.nextBool()) ? n : -n;
  }

  /// Returns a 64-bit random number between [min] and [max] inclusive,
  /// Where [min] >= 0, and [max] >= min && [max] <= [kInt64Max].
  int nextUint([int min = 0, int max = kInt64Max]) {
    RangeError.checkValueInInterval(min, 0, kInt64Max, 'min');
    RangeError.checkValueInInterval(max, min, kInt64Max, 'max');
    final limit = max - min;
    if (limit < 0 || limit > kInt64Max)
      // ignore: only_throw_errors
      throw 'Invalid range error: 0 > $max - $min = $limit < 0xFFFFFFFF';
    return (limit < kUint32Max)
        ? generator.nextInt(limit + 1) + min
        : _nextUint64().remainder(limit + 1);
  }

  /// Returns a random 7-bit unsigned integer ([int]), i.e. an ASCII code unit.
  int get nextUint7 => _nextUint32(0, 127);

  /// Returns a random 8-bit unsigned integer ([int]).
  int get nextUint8 => _nextUint32(0, kUint8Max);

  /// Returns a random [Uint8List] with a length between [minLength] and
  /// [maxLength] inclusive. The [List] will contain 8-bit unsigned integers.
  Uint8List uint8List([int minLength, int maxLength]) {
    final length = _getLength(minLength, maxLength);
    final v = Uint8List(length);
    for (var i = 0; i < length; i++) v[i] = nextUint8;
    return v;
  }

  /// Returns a random 16-bit unsigned integer ([int]).
  int get nextUint16 => _nextUint32(0, kUint16Max);

  /// Returns a random [Uint16List] with a length between [minLength] and
  /// [maxLength] inclusive. The [List] will contain 16-bit unsigned integers.
  Uint16List uint16List([int minLength, int maxLength]) {
    final length = _getLength(minLength, maxLength);
    final v = Uint16List(length);
    for (var i = 0; i < length; i++) v[i] = nextUint16;
    return v;
  }

  /// Returns a random 32-bit unsigned integer ([int]).
  int get nextUint32 => _nextUint32(0, kUint32Max);

  /// Returns a random [Uint32List] with a length between [minLength] and
  /// [maxLength] inclusive. The [List] will contain 32-bit unsigned integers.
  Uint32List uint32List([int minLength, int maxLength]) {
    final length = _getLength(minLength, maxLength);
    final v = Uint32List(length);
    for (var i = 0; i < length; i++) v[i] = nextUint32;
    return v;
  }

  /// Returns a 32-bit random number between [min] and [max] inclusive.
  int _nextUint32(int min, int max) {
    final limit = (max - min) + 1;
    assert(limit <= 1 << 32);
    return generator.nextInt(limit) + min;
  }

  /// Returns a random 64-bit unsigned integer ([int]).
  int get nextUint64 => _nextUint64();

  /// Returns a random [Uint64List] with a length between [minLength] and
  /// [maxLength] inclusive. The [List] will contain 64-bit unsigned integers.
  Uint64List uint64List([int minLength, int maxLength]) {
    final length = _getLength(minLength, maxLength);
    final v = Uint64List(length);
    for (var i = 0; i < length; i++) v[i] = nextUint64;
    return v;
  }

  /// Returns a 64-bit random unsigned integer _n_, in the range
  /// 0 >= n <= [kInt64Max]
  int _nextUint64() {
    final upper = generator.nextInt(kUint32Max);
    final lower = generator.nextInt(kUint32Max);
    final n = (upper << 31) | lower;
    assert(n >= 0 && n <= kInt64Max, 'n = $n');
    return n;
  }

  static final Float32List _float32box = Float32List(1);

  /// Returns a [double] between the most-negative and most-positive 32-bit
  /// signed integers.
  double get _nextFloat => generator.nextDouble() * _nextUint32(0, kUint32Max);

  /// Returns a double in the range of an IEEE 32-bit floating point number.
  double get nextFloat32 {
    final n = _nextFloat;
    _float32box[0] = n;
    return _float32box[0];
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

  /// Returns a [double] between the most-negative and most-positive 32-bit
  /// signed integers.
  double get nextFloat64 => _nextFloat;

  /// Returns a random [Float64List] with a length between [minLength] and
  /// [maxLength] inclusive. The [List] will contain 64-bit floating point
  /// numbers.
  Float64List float64List([int minLength, int maxLength]) {
    final length = _getLength(minLength, maxLength);
    final v = Float64List(length);
    for (var i = 0; i < length; i++) v[i] = nextFloat64;
    return v;
  }

  /// Returns a [double] with value between 0 and 1.
  double get nextDouble => generator.nextDouble();

  /// Returns a random [List<double>] with a length between [minLength] and
  /// [maxLength] inclusive, containing values between 0 and 1.
  List<double> doubleList([int minLength, int maxLength]) {
    final len = _getLength(minLength, maxLength);
    final vList = List<double>(len);
    for (var i = 0; i < len; i++) vList[i] = generator.nextDouble();
    return vList;
  }

  /// Returns a [List<ByteData>].
  ByteData byteDataList(int min, int max, [int minLength, int maxLength]) {
    RangeError.checkValueInInterval(min, kUint8Min, kUint8Max, 'Min');
    RangeError.checkValueInInterval(max, min, kUint32Max, 'Max');
    final len = _getLength(minLength, maxLength);
    final vList = ByteData(len);
    for (var i = 0; i < len; i++) vList.setUint8(i, nextInt(min, max));
    return vList;
  }

  /// Returns a [String] containing a single ASCII digit character
  /// (code point) between 0 and 9.
  String get nextDigit => String.fromCharCode(_nextDigit);

  /// Returns an ASCII digit character (code point) between 0 and 9.
  int get _nextDigit => _nextUint32($0, $9);

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

    sb.writeCharCode(_nextDigit);
    for (var i = sb.length; i < len; i++) sb.writeCharCode(_nextDigit);
    final s = sb.toString();
    RangeError.checkValidRange(1, s.length, 16);
    return s;
  }

  static bool _always(int c) => true;

  /// Returns an ASCII character (code point). [predicate]
  /// defaults to always _true_.
  int nextAsciiSatisfying([bool predicate(int char) = _always]) {
    final c = nextUint7;
    return (predicate(c)) ? c : nextAsciiSatisfying(predicate);
  }

  /// Returns an ASCII character (code point), i.e. in range 0 - 127 inclusive.
  int get nextAsciiChar => nextUint7;

  /// Returns a visible (printing) ASCII character (code point),
  /// i.e. [$space](0x20) and [$tilde] (0x7E) inclusive.
  int get nextAsciiVChar => _nextUint32($space, $tilde);

  /// Returns a random [Uint8List] with a length between [minLength] and
  /// [maxLength] inclusive, containing visible ASCII code points
  /// (see [nextAsciiVChar]), which corresponds to an ASCII String.
  Uint8List asciiBytes([int minLength, int maxLength]) {
    final length = _getLength(minLength, maxLength);
    final len = length.isEven ? length : length + 1;
    final v = Uint8List(len);
    for (var i = 0; i < length; i++) v[i] = nextAsciiVChar;
    return v;
  }

  /// Returns [String] with a length between [minLength] and
  /// [maxLength] inclusive, containing visible ASCII code units
  /// (see [nextAsciiVChar]).
  String asciiString([int minLength, int maxLength]) {
    final bytes = asciiBytes(minLength, maxLength);
    return cvt.latin1.decode(bytes, allowInvalid: true);
  }

  /// Returns a random [List<String>] containing ASCII Strings with
  /// length between [minLength] and [maxLength] inclusive.
  List<String> asciiList([int minLength, int maxLength]) {
    final length = _getLength(minLength, maxLength);
    final list = List<String>(length);
    for (var i = 0; i < length; i++) list[i] = asciiString();
    return list;
  }

  /// Returns a visible (printing) Latin character (code point).
  int get nextLatinChar => _nextLatinChar();

  int _nextLatinChar() {
    final c = _nextUint32(0x20, 0xFF);
    return ((c >= 0x7F && c <= 0x9F) || c < 32) ? _nextLatinChar : c;
  }

  /// Returns a random [Uint8List] with a length between [minLength]
  /// and[maxLength] inclusive, containing Latin code points,
  /// except '\' ([$backslash]).
  Uint8List latinBytes([int minLength, int maxLength]) {
    final length = _getLength(minLength, maxLength);
    final list = Uint8List(length);
    for (var i = 0; i < length; i++) list[i] = _nextLatinChar();
    return list;
  }

  /// Returns [String] containing visible Latin code points
  /// with a length between [minLength] and [maxLength] inclusive.
  String latinString([int minLength, int maxLength]) {
    final bytes = latinBytes(minLength, maxLength);
    return cvt.latin1.decode(bytes, allowInvalid: true);
  }

  /// Returns a random [List<String>] containing Latin Strings with
  /// length between [minLength] and [maxLength] inclusive.
  List<String> latinList([int minLength, int maxLength]) {
    final length = _getLength(minLength, maxLength);
    final list = List<String>(length);
    for (var i = 0; i < length; i++) list[i] = latinString();
    return list;
  }

  /// Returns a Utf8 code point, i.e. between 32 and 255.
  int get nextUtf8 => _nextUtf8;

  // TODO this should be generating valid UTF8 code units.
  /// Returns a Utf8 code point, i.e. between 32 and 255.
  int get _nextUtf8 => _nextLatinChar();

  /// Returns a random [Uint8List] with a length between [minLength] and
  /// [maxLength] inclusive, corresponding to a UTF-8 String.
  Uint8List utf8Bytes([int minLength, int maxLength]) {
    final length = _getLength(minLength, maxLength);
    final len = length.isEven ? length : length + 1;
    final v = Uint8List(len);
    for (var i = 0; i < length; i++) v[i] = _nextUtf8;
    return v;
  }

  /// Returns [String] of [length] containing UTF-8 code units in the range
  /// from 0 to 255. If [length] is specified, the returned [String] will
  /// have that [length]; otherwise, it will have a random length, between 4
  /// and 1024 inclusive. _Note_: While the returned [String] will contain
  /// UTF-8 code units, they will not necessarily be valid code points.
  String utf8String([int length]) {
    length ??= nextUint(defaultMinStringLength, 4096);
    RangeError.checkValueInInterval(length, 0, 4096, 'length');
    final v = Uint8List(length);
    for (var i = 0; i < length; i++) v[i] = nextUint8;
    return cvt.utf8.decode(v, allowMalformed: true);
  }

  /// Returns a random [List<String>] containing UTF-8 Strings with
  /// length between [minLength] and [maxLength] inclusive.
  List<String> utf8List([int minLength, int maxLength]) {
    final length = _getLength(minLength, maxLength);
    final list = List<String>(length);
    for (var i = 0; i < length; i++) list[i] = utf8String();
    return list;
  }

  // Always returns a positive integer that is less than Int32Max.
  int _getLimit(int min, int max) {
    assert(min >= 0 && max <= kInt64Max && min <= max);
    final limit = max - min;
    assert(limit >= 0 || limit <= kInt64Max, 'limit = $limit');
    return (limit < 0) ? -limit : limit;
  }

  // Always returns a positive integer that is less than Int32Max.
  int _getLimit32(int min, int max) {
    assert(min >= kInt32Min);
    assert(max <= kInt32Max);
    var limit = max - min;
    if (limit < 0) limit = -limit;
    if (limit > kUint32Max) limit = kUint32Max;
    return limit;
  }

  /// Returns a random a length between [minLength] and [maxLength] inclusive.
  /// [minLength] must be greater than or equal to 0, and [maxLength] must
  /// be less than or equal to 2^31-1, i.e. the maximum 32-bit signed positive
  /// integer.
  int getLength([int minLength, int maxLength]) =>
      _getLength(minLength, maxLength);

  int _getLength([int min, int max]) {
    min ??= defaultMinListLength;
    max ??= defaultMaxListLength;
    if (max == 0) return 0;
    return nextUint(min, max);
  }
}
