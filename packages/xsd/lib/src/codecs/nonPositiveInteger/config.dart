import 'package:xsd/src/helpers/whitespace.dart';

/// Values taken from the specification
final nonPositiveIntegerConstraints = (
  maxInclusive: 0,
  pattern: RegExp(r'[\-+]?[0-9]+'),
  whitespace: Whitespace.collapse,
);
