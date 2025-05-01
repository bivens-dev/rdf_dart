import 'package:xsd/src/helpers/whitespace.dart';

/// Values taken from the specification
final unsignedIntConstraints = (
  minInclusive: 0,
  maxInclusive: 4294967295,
  pattern: RegExp(r'[\-+]?[0-9]+'),
  whitespace: Whitespace.collapse,
);
