import 'package:xsd/src/helpers/whitespace.dart';

/// Values taken from the specification
final unsignedShortConstraints = (
  minInclusive: 0,
  maxInclusive: 65535,
  pattern: RegExp(r'[\-+]?[0-9]+'),
  whitespace: Whitespace.collapse,
);
