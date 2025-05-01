import 'package:xsd/src/helpers/whitespace.dart';

/// Values taken from the specification
final negativeIntegerConstraints = (
  maxInclusive: -1,
  pattern: RegExp(r'[\-+]?[0-9]+'),
  whitespace: Whitespace.collapse,
);
