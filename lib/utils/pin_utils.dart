import 'dart:math';

final _random = Random();

int generate4DigitPin() => _random.nextInt(9000) + 1000;
