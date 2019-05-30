// Copyright (c) 2016, Open DICOMweb Project. All rights reserved.
// Use of this source code is governed by the open source license
// that can be found in the LICENSE file.
// Original author: Jim Philbin <jfphilbin@gmail.edu> -
// See the AUTHORS file for other contributors.
//

// ignore_for_file: public_member_api_docs

const int kMinLength = 16;

const int kInt8Size = 1;
const int kInt16Size = 2;
const int kInt32Size = 4;
const int kInt64Size = 8;

const int kInt8Min = -0x7F - 1;
const int kInt16Min = -0x7FFF - 1;
const int kInt32Min = -0x7FFFFFFF - 1;
const int kInt64Min = -0x7FFFFFFFFFFFFFFF - 1;

const int kInt8Max = 0x7F;
const int kInt16Max = 0x7FFF;
const int kInt32Max = 0x7FFFFFFF;
const int kInt64Max = 0x7FFFFFFFFFFFFFFF;

const int kUint8Size = 1;
const int kUint16Size = 2;
const int kUint32Size = 4;
const int kUint64Size = 8;

const int kUint8Min = 0;
const int kUint16Min = 0;
const int kUint32Min = 0;
const int kUint64Min = 0;

const int kUint8Max = 0xFF;
const int kUint16Max = 0xFFFF;
const int kUint32Max = 0xFFFFFFFF;
const int kUint64Max = 0xFFFFFFFFFFFFFFFF;

const int kFloat32Size = 4;
const int kFloat64Size = 8;

const int kDefaultLength = 4096;

const int kDefaultLimit = 1024 * 1024 * 1024; // 1 GB
