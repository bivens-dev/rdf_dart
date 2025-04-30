import 'package:xsd/src/helpers/whitespace.dart';

/// Values taken from the specification
  final decimalConstraints = (
    pattern: RegExp(r'(\+|-)?([0-9]+(\.[0-9]*)?|\.[0-9]+)'),
    whitespace: Whitespace.collapse,
  );