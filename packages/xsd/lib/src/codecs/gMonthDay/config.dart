import 'package:xsd/src/helpers/whitespace.dart';

/// Values taken from the specification
final gMonthDayconstraints = (whitespace: Whitespace.collapse);

// Regex: --MM-DD[TZ]
// Group 1: MM
// Group 2: DD
// Group 3: TZ part (optional)
// Group 4: Z
// Group 5: +/- sign
// Group 6: TZ hh
// Group 7: TZ mm
final gMonthDayRegex = RegExp(
  r'^--(\d{2})-(\d{2})(?:(Z)|([+-])(\d{2}):(\d{2}))?$',
);
