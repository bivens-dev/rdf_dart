import 'package:xsd/src/helpers/whitespace.dart';

final byteConstraints = (
    minInclusive: -128,
    maxInclusive: 127,
    pattern: RegExp(r'[\-+]?[0-9]+'),
    whitespace: Whitespace.collapse,
  );