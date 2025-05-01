import 'package:xsd/src/helpers/whitespace.dart';

/// Values taken from the specification
final shortConstraints = (
  minInclusive: -32768,
  maxInclusive: 32767,
  pattern: RegExp(r'[\-+]?[0-9]+'),
  whitespace: Whitespace.collapse,
);
