import 'package:xsd/src/helpers/whitespace.dart';

/// Values taken from the specification
final booleanConstraints = (
  pattern: RegExp(r'^(true|false|1|0)$'),
  whitespace: Whitespace.collapse,
);
