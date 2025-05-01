import 'package:xsd/src/helpers/whitespace.dart';

/// Values taken from the specification
final unsignedLongConstraints = (
  minInclusive: BigInt.from(0),
  maxInclusive: BigInt.parse('18446744073709551615'),
  pattern: RegExp(r'[\-+]?[0-9]+'),
  whitespace: Whitespace.collapse,
);
