import 'package:xsd/src/helpers/whitespace.dart';

/// Values taken from the specification
final longConstraints = (
  minInclusive: BigInt.parse('-9223372036854775808'),
  maxInclusive: BigInt.parse('9223372036854775807'),
  pattern: RegExp(r'[\-+]?[0-9]+'),
  whitespace: Whitespace.collapse,
);
