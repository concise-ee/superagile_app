import 'package:flutter/foundation.dart';

enum UserRole {
  PLAYER,
  HOST,
}

extension StringExtensions on UserRole {
  String get toExactString => describeEnum(this);
}

UserRole toRoleEnum(String enumString) => UserRole.values.singleWhere((e) => e.toExactString == enumString);
