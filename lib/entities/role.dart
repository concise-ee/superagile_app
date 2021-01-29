import 'package:flutter/foundation.dart';

enum Role {
  PLAYER,
  HOST,
}

extension StringExtensions on Role {
  String get toExactString => describeEnum(this);
}

Role toRoleEnum(String enumString) => Role.values.singleWhere((e) => e.toExactString == enumString);
