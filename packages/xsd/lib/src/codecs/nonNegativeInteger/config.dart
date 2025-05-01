import 'package:xsd/src/helpers/whitespace.dart';

/// Values taken from the specification
final nonNegativeIntegerConstraints = (
  minInclusive: 0,
  pattern: RegExp(r'[\-+]?[0-9]+'),
  whitespace: Whitespace.collapse,
);
