import 'package:rdf_dart/src/iri.dart';
import 'package:rdf_dart/src/model/blank_node.dart';
import 'package:rdf_dart/src/model/literal.dart';
import 'package:rdf_dart/src/vocab/xsd_vocab.dart' show XSD;

// ignore: avoid_classes_with_only_static_members
/// Utility functions for serializing RDF terms into N-Triples/N-Quads format.
class NFormatsSerializerUtils {
  /// Creates a UCHAR escape sequence (`\\uXXXX` or `\\UXXXXXXXX`) for a rune.
  ///
  /// This is used for escaping characters in IRIs and string literals according
  /// to the N-Triples/N-Quads specifications.
  /// - For runes within the Basic Multilingual Plane (BMP, <= U+FFFF),
  ///   it returns a `\\u` sequence with 4 hex digits.
  /// - For runes outside the BMP (> U+FFFF), it returns a `\\U` sequence
  ///   with 8 hex digits.
  ///
  /// Parameters:
  ///   [rune]: The Unicode code point (integer) to escape.
  ///
  /// Returns:
  ///   The N-Triples/N-Quads UCHAR escape string.
  static String escapeRune(int rune) {
    if (rune <= 0xFFFF) {
      // Use \u for BMP characters
      return '\\u${rune.toRadixString(16).toUpperCase().padLeft(4, '0')}';
    } else {
      // Use \U for characters outside BMP
      return '\\U${rune.toRadixString(16).toUpperCase().padLeft(8, '0')}';
    }
  }

  /// Escapes a string according to N-Triples/N-Quads STRING_LITERAL_QUOTE rules.
  ///
  /// Replaces mandatory escapes `\\`, `"`, `\\n`, `\\r`.
  /// Also replaces optional ECHAR `\\t`, `\\b`, `\\f`.
  /// Uses UCHAR escapes for control characters U+00-U+1F (excluding already
  /// handled ones) and U+7F.
  ///
  /// Parameters:
  ///   [input]: The string to escape.
  ///
  /// Returns:
  ///   The escaped string suitable for inclusion within quotes in N-Triples/N-Quads.
  static String escapeString(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      switch (rune) {
        case 0x22: // " Quotation mark
          buffer.write(r'\"');
        case 0x5C: // \ Backslash
          buffer.write(r'\\');
        case 0x0A: // \n Line Feed
          buffer.write(r'\n');
        case 0x0D: // \r Carriage Return
          buffer.write(r'\r');
        case 0x09: // \t Tab
          buffer.write(r'\t');
        case 0x08: // \b Backspace (BS)
          buffer.write(r'\b');
        case 0x0C: // \f Form Feed (FF)
          buffer.write(r'\f');
        default:
          // Use UCHAR for other control characters (U+00-U+1F, excluding \t, \n, \r, \b, \f)
          // and DEL (U+7F), matching original encoder logic.
          if ((rune >= 0x00 && rune <= 0x07) || // Before BS (\b)
              rune == 0x0B || // Vertical Tab (After LF \n, Before FF \f)
              (rune >= 0x0E && rune <= 0x1F) || // After CR (\r) up to US
              rune == 0x7F) {
            // DEL
            buffer.write(escapeRune(rune));
          } else {
            // Append other characters (printable ASCII, high-value UTF-8) directly
            buffer.writeCharCode(rune);
          }
      }
    }
    return buffer.toString();
  }

  /// Escapes characters within an IRI string if necessary for N-Triples/N-Quads.
  ///
  /// According to the IRIREF production, characters from U+00 to U+20,
  /// `<`, `>`, `"`, `{`, `}`, `|`, `^`, ``` `` ```, and `\` must be escaped using UCHAR.
  ///
  /// Parameters:
  ///   [iriString]: The IRI string to format.
  ///
  /// Returns:
  ///   The escaped IRI string suitable for inclusion within `<>`.
  static String escapeIriString(String iriString) {
    final buffer = StringBuffer();
    for (final rune in iriString.runes) {
      if (rune <= 0x20 || // Control characters U+00 to U+20
          rune == 0x3C || // <
          rune == 0x3E || // >
          rune == 0x22 || // "
          rune == 0x7B || // {
          rune == 0x7D || // }
          rune == 0x7C || // |
          rune == 0x5E || // ^
          rune == 0x60 || // `
          rune ==
              0x5C // \
              ) {
        buffer.write(escapeRune(rune));
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  /// Formats an [IRI] value into N-Triples/N-Quads `<IRI>` format.
  ///
  /// Parameters:
  ///   [iri]: The IRI value to format.
  ///
  /// Returns:
  ///   The formatted IRI string (e.g., `<http://example.org/resource>`).
  static String formatIri(IRI iri) {
    final escapedValue = escapeIriString(iri.originalValue);
    return '<$escapedValue>';
  }

  /// Formats a [BlankNode] into N-Triples/N-Quads `_:label` format.
  ///
  /// Parameters:
  ///   [bnode]: The blank node to format.
  ///
  /// Returns:
  ///   The formatted blank node string (e.g., `_:b0`).
  static String formatBlankNode(BlankNode bnode) {
    // Assumes bnode.id conforms to BLANK_NODE_LABEL syntax rules.
    // Validation should happen during BlankNode creation.
    return '_:${bnode.id}';
  }

  /// Formats a [Literal] into N-Triples/N-Quads format.
  ///
  /// Handles lexical form escaping, language tags (including directionality),
  /// and datatype IRIs according to RDF 1.2 N-Triples/N-Quads specs.
  ///
  /// Parameters:
  ///   [literal]: The literal to format.
  ///
  /// Returns:
  ///   The formatted literal string (e.g., `"A literal"`, `"chat"@en`,
  ///   `"rtl text"@ar--rtl`, `"123"^^<xsd:integer>`).
  static String formatLiteral(Literal literal) {
    final escapedLexicalForm = escapeString(literal.lexicalForm);
    final buffer = StringBuffer('"');
    buffer.write(escapedLexicalForm);
    buffer.write('"');

    if (literal.language != null) {
      // Language tag validation should happen during Literal creation.
      buffer.write('@');
      buffer.write(literal.language!);

      // RDF 1.2 Directionality suffix
      if (literal.baseDirection != null) {
        buffer.write('--');
        buffer.write(
          literal.baseDirection == TextDirection.ltr ? 'ltr' : 'rtl',
        );
      }
      // Datatype for language-tagged strings (rdf:langString or rdf:dirLangString)
      // MUST NOT be written explicitly.
    } else if (literal.datatype != XSD.string) {
      // Datatype is not xsd:string and no language tag exists.
      // Append ^^<datatypeIRI>. Simple literals (implicit xsd:string) don't get suffix.
      buffer.write('^^');
      buffer.write(formatIri(literal.datatype)); // Reuse IRI formatting
    }
    // If datatype is xsd:string and no language tag/direction, nothing is appended.

    return buffer.toString();
  }
}
