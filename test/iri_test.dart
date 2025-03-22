import 'package:rdf_dart/rdf_dart.dart';
import 'package:test/test.dart';

void main() {
  group('IRI', () {
    group('Valid IRIs', () {
      test('http scheme', () {
        expect(() => IRI('http://example.com'), returnsNormally);
      });

      test('https scheme', () {
        expect(() => IRI('https://example.com/path'), returnsNormally);
      });

      test('ftp scheme', () {
        expect(() => IRI('ftp://example.com'), returnsNormally);
      });

      test('file scheme', () {
        expect(() => IRI('file:///path/to/file'), returnsNormally);
      });

      test('urn scheme', () {
        expect(() => IRI('urn:isbn:0451450523'), returnsNormally);
      });

      test('with query parameters', () {
        expect(() => IRI('https://example.com/search?q=test'), returnsNormally);
      });

      test('with fragment', () {
        expect(() => IRI('https://example.com/page#section'), returnsNormally);
      });

      test('with port number', () {
        expect(() => IRI('http://example.com:8080'), returnsNormally);
      });
      test('with path', () {
        expect(
          () => IRI('http://example.com/path/to/resource'),
          returnsNormally,
        );
      });
      test('internationalized', () {
        expect(
          () => IRI('http://www.example.com/r\u00e9sum\u00e9'),
          returnsNormally,
        );
      });
      test('percent encoded', () {
        expect(
          () => IRI('http://www.example.com/res%20ource'),
          returnsNormally,
        );
      });

      test('with complex characters', () {
        expect(
          () => IRI('http://example.com/path/to/resource?query=value#fragment'),
          returnsNormally,
        );
      });
    });

    group('Valid Percent-Encoded IRIs', () {
      test('with correct spaces', () {
        expect(
          () => IRI('http://example.com/path%20with%20spaces'),
          returnsNormally,
        );
      });
      test('with correct upper case', () {
        expect(() => IRI('http://example.com/%41bc'), returnsNormally);
      });
      test('with several percent-encoding', () {
        expect(() => IRI('http://example.com/%41%42%43'), returnsNormally);
      });
      test('with simple encoding', () {
        expect(() => IRI('http://example.com/%4a'), returnsNormally);
      });
    });

    group('Invalid Percent-Encoded IRIs', () {
      test('with invalid character after percent', () {
        expect(
          () => IRI('http://example.com/path%2 with spaces'),
          throwsFormatException,
        );
      });
      test('with invalid hex character', () {
        expect(() => IRI('http://example.com/path%2G'), throwsFormatException);
      });
      test('with invalid hex characters', () {
        expect(() => IRI('http://example.com/path%GG'), throwsFormatException);
      });
      test('with missing hex digits', () {
        expect(() => IRI('http://example.com/path%'), throwsFormatException);
      });
      test('with only one hex digit', () {
        expect(() => IRI('http://example.com/%2'), throwsFormatException);
      });
      test('with only one hex digit', () {
        expect(() => IRI('http://example.com/%a%b'), throwsFormatException);
      });
      test('with incorrect hex encoding', () {
        expect(() => IRI('http://example.com/path%2GH'), throwsFormatException);
      });
    });

    group('Invalid Control Character IRIs', () {
      test('with U+0000 (NUL)', () {
        expect(() => IRI('http://example.com/\u0000'), throwsFormatException);
      });

      test('with U+0001 (SOH)', () {
        expect(() => IRI('http://example.com/\u0001'), throwsFormatException);
      });

      test('with U+001F (US)', () {
        expect(() => IRI('http://example.com/\u001F'), throwsFormatException);
      });

      test('with U+007F (DEL)', () {
        expect(() => IRI('http://example.com/\u007F'), throwsFormatException);
      });

      test('with U+0080', () {
        expect(() => IRI('http://example.com/\u0080'), throwsFormatException);
      });

      test('with U+009F', () {
        expect(() => IRI('http://example.com/\u009F'), throwsFormatException);
      });

      test('with U+0000 in percent-encoded sequence', () {
        expect(() => IRI('http://example.com/%00'), returnsNormally);
      });

      test('with U+007F in percent-encoded sequence', () {
        expect(() => IRI('http://example.com/%7F'), returnsNormally);
      });

      test('with U+0080 in percent-encoded sequence', () {
        expect(() => IRI('http://example.com/%C2%80'), returnsNormally);
      });
      test('with U+009F in percent-encoded sequence', () {
        expect(() => IRI('http://example.com/%C2%9F'), returnsNormally);
      });
      test('with TAB', () {
        expect(() => IRI('http://example.com/\t'), throwsFormatException);
      });
      test('with CR', () {
        expect(() => IRI('http://example.com/\r'), throwsFormatException);
      });
      test('with LF', () {
        expect(() => IRI('http://example.com/\n'), throwsFormatException);
      });
    });

    group('Invalid IRIs', () {
      test('with space', () {
        expect(() => IRI('http://example.com /path'), throwsFormatException);
      });
      test('with newline', () {
        expect(() => IRI('http://example.com\n'), throwsFormatException);
      });
      test('empty string', () {
        expect(() => IRI(''), throwsFormatException);
      });
      test('invalid character', () {
        expect(() => IRI('http://example.com/{path}'), throwsFormatException);
      });
      test('only :', () {
        expect(() => IRI(':'), throwsFormatException);
      });
    });
    group('Equality', () {
      test('equal IRIs', () {
        final iri1 = IRI('http://example.com');
        final iri2 = IRI('http://example.com');
        expect(iri1 == iri2, true);
      });
      test('different IRIs', () {
        final iri1 = IRI('http://example.com');
        final iri2 = IRI('https://example.com');
        expect(iri1 == iri2, false);
      });
    });
    group('HashCode', () {
      test('equal IRIs', () {
        final iri1 = IRI('http://example.com');
        final iri2 = IRI('http://example.com');
        expect(iri1.hashCode == iri2.hashCode, true);
      });
      test('different IRIs', () {
        final iri1 = IRI('http://example.com');
        final iri2 = IRI('https://example.com');
        expect(iri1.hashCode == iri2.hashCode, false);
      });
    });
    group('TermType', () {
      test('term type is IRI', () {
        final iri = IRI('http://example.com');
        expect(iri.termType, TermType.iri);
      });
    });
  });
}
