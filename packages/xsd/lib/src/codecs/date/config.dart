import 'package:xsd/src/helpers/whitespace.dart';

final dateConstraints = (
    /// Whitespace processing rule for `xsd:date`.
    whitespace: Whitespace.collapse,

    /// Original regex from the XSD 1.1 specification for validation.
    lexicalSpace: RegExp(
      r'^(-?(?:[1-9][0-9]{3,}|0[0-9]{3}))-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])(Z|([+-])([01][0-9]|1[0-3]):([0-5][0-9])|14:00)?$',
    ),

    /// Refined regex used for parsing, making the optional timezone group capturing
    /// and adjusting sub-group indices for easier extraction in [parseTimeZone].
    refinedRegex: RegExp(
      // Year part (Group 1)
      '^(-?(?:[1-9][0-9]{3,}|0[0-9]{3}))'
      '-'
      // Month part (Group 2)
      '(0[1-9]|1[0-2])'
      '-'
      // Day part (Group 3)
      '(0[1-9]|[12][0-9]|3[01])'
      // Start Capturing Group 4 (Optional Full Timezone)
      '('
      // Z alternative (Group 5)
      '(Z)'
      '|'
      // Offset < 14h alternative (Groups 6, 7, 8)
      '([+-])(0[0-9]|1[0-3]):([0-5][0-9])'
      '|'
      // Offset = 14h alternative (Groups 9, 10)
      '([+-])(14):00'
      r')?$', // End Group 4 and Anchor
    ),
  );