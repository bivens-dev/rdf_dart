import 'package:xsd/src/helpers/whitespace.dart';

/// Values taken from the specification
final integerConstraints = (
  pattern: RegExp(r'[\-+]?[0-9]+'),
  whitespace: Whitespace.collapse,
);
