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
        expect(() => IRI('http://example.com/path/to/resource'), returnsNormally);
      });
      test('internationalized', () {
        expect(() => IRI('http://www.example.com/r\u00e9sum\u00e9'), returnsNormally);
      });
      test('percent encoded', () {
        expect(() => IRI('http://www.example.com/res%20ource'), returnsNormally);
      });

      test('with complex characters', () {
        expect(() => IRI('http://example.com/path/to/resource?query=value#fragment'), returnsNormally);
      });
    });

    group('Invalid IRIs', () {
      // test('with space', () {
      //   expect(() => IRI('http://example.com /path'), throwsA(isA<InvalidIRIException>()));
      //   try{
      //     IRI('http://example.com /path');
      //   } on InvalidIRIException catch (e){
      //     expect(e.message, contains('Invalid IRI: http://example.com /path - Error:'));
      //   }
      // });
      // test('with newline', () {
      //   expect(
      //       () => IRI('http://example.com\n'),
      //       throwsA(isA<InvalidIRIException>()
      //           .having((e) => e.message, 'message', contains('Invalid IRI: http://example.com\n - Error:'))));
      // });
      // test('relative without base', () {
      //   expect(
      //       () => IRI('/path'),
      //       throwsA(isA<InvalidIRIException>()
      //           .having((e) => e.message, 'message', contains('Invalid IRI: /path - Error:'))));
      // });
      // test('empty string', () {
      //   expect(
      //       () => IRI(''),
      //       throwsA(isA<InvalidIRIException>()
      //           .having((e) => e.message, 'message', contains('Invalid IRI:  - Error:'))));
      // });
      // test('invalid character', () {
      //   expect(
      //       () => IRI('http://example.com/{path}'),
      //       throwsA(isA<InvalidIRIException>()
      //           .having((e) => e.message, 'message', contains('Invalid IRI: http://example.com/{path} - Error:'))));
      // });
      // test('without scheme', () {
      //   expect(
      //       () => IRI('example.com'),
      //       throwsA(isA<InvalidIRIException>()
      //           .having((e) => e.message, 'message', contains('Invalid IRI: example.com - Error:'))));
      // });
      test('only :', () {
        expect(
            () => IRI(':'),
            throwsA(isA<InvalidIRIException>()
                .having((e) => e.message, 'message', contains('Invalid IRI: : - Error:'))));
      });
    });
    group('Equality', () {
      test('equal IRIs', () {
        IRI iri1 = IRI("http://example.com");
        IRI iri2 = IRI("http://example.com");
        expect(iri1 == iri2, true);
      });
      test('different IRIs', () {
        IRI iri1 = IRI("http://example.com");
        IRI iri2 = IRI("https://example.com");
        expect(iri1 == iri2, false);
      });
    });
    group('HashCode', () {
      test('equal IRIs', () {
        IRI iri1 = IRI("http://example.com");
        IRI iri2 = IRI("http://example.com");
        expect(iri1.hashCode == iri2.hashCode, true);
      });
      test('different IRIs', () {
        IRI iri1 = IRI("http://example.com");
        IRI iri2 = IRI("https://example.com");
        expect(iri1.hashCode == iri2.hashCode, false);
      });
    });
    group('TermType', () {
      test('term type is IRI', () {
        IRI iri = IRI("http://example.com");
        expect(iri.termType, TermType.iri);
      });
    });
  });
}
