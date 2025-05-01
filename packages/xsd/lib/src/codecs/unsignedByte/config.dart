import 'package:xsd/src/helpers/whitespace.dart';

/// Values taken from the specification
final unsignedByteConstraints = (
  minInclusive: 0,
  maxInclusive: 255,
  pattern: RegExp(r'[\-+]?[0-9]+'),
  whitespace: Whitespace.collapse,
);
