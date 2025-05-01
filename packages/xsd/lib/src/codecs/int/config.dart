 import 'package:xsd/src/helpers/whitespace.dart';

/// Values taken from the specification
  final intConstraints = (
    minInclusive: -2147483648,
    maxInclusive: 2147483647,
    pattern: RegExp(r'[\-+]?[0-9]+'),
    whitespace: Whitespace.collapse,
  );