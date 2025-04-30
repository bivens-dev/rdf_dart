import 'package:rdf_dart/src/data_types/helper.dart';
import 'package:test/test.dart';

void main() {
  group('processWhiteSpace', () {
    test('Preserve - Empty string', () {
      expect(processWhiteSpace('', Whitespace.preserve), equals(''));
    });

    test('Preserve - String with spaces', () {
      expect(
        processWhiteSpace('  Hello World  ', Whitespace.preserve),
        equals('  Hello World  '),
      );
    });

    test('Preserve - String with tabs, line feeds, and carriage returns', () {
      expect(
        processWhiteSpace('\tHello\nWorld\r!', Whitespace.preserve),
        equals('\tHello\nWorld\r!'),
      );
    });

    test('Replace - Empty string', () {
      expect(processWhiteSpace('', Whitespace.replace), equals(''));
    });

    test('Replace - String with spaces', () {
      expect(
        processWhiteSpace('  Hello   World  ', Whitespace.replace),
        equals('  Hello   World  '),
      );
    });

    test('Replace - String with tab', () {
      expect(
        processWhiteSpace('Hello\tWorld', Whitespace.replace),
        equals('Hello World'),
      );
    });

    test('Replace - String with line feed', () {
      expect(
        processWhiteSpace('Hello\nWorld', Whitespace.replace),
        equals('Hello World'),
      );
    });

    test('Replace - String with carriage return', () {
      expect(
        processWhiteSpace('Hello\rWorld', Whitespace.replace),
        equals('Hello World'),
      );
    });

    test('Replace - String with mixed whitespace', () {
      expect(
        processWhiteSpace(' \tHello\nWorld\r! \r\n', Whitespace.replace),
        equals('  Hello World !   '),
      );
    });

    test('Collapse - Empty string', () {
      expect(processWhiteSpace('', Whitespace.collapse), equals(''));
    });

    test('Collapse - String with spaces', () {
      expect(
        processWhiteSpace('  Hello   World  ', Whitespace.collapse),
        equals('Hello World'),
      );
    });

    test('Collapse - String with tab', () {
      expect(
        processWhiteSpace('Hello\tWorld', Whitespace.collapse),
        equals('Hello World'),
      );
    });

    test('Collapse - String with line feed', () {
      expect(
        processWhiteSpace('Hello\nWorld', Whitespace.collapse),
        equals('Hello World'),
      );
    });

    test('Collapse - String with carriage return', () {
      expect(
        processWhiteSpace('Hello\rWorld', Whitespace.collapse),
        equals('Hello World'),
      );
    });

    test('Collapse - String with mixed whitespace', () {
      expect(
        processWhiteSpace(' \tHello\nWorld\r! \r\n', Whitespace.collapse),
        equals('Hello World !'),
      );
    });

    test('Collapse - String with only whitespace', () {
      expect(processWhiteSpace(' \t\n\r ', Whitespace.collapse), equals(''));
    });
    test('Collapse - String with leading and trailing spaces', () {
      expect(
        processWhiteSpace('   Hello   ', Whitespace.collapse),
        equals('Hello'),
      );
    });
    test('Collapse - String with leading and trailing mixed whitespace', () {
      expect(
        processWhiteSpace('\t  \r\n Hello \t  \r\n', Whitespace.collapse),
        equals('Hello'),
      );
    });
    test('Collapse - String with multiple spaces and mixed whitespace', () {
      expect(
        processWhiteSpace(
          '  \t  Hello   \n World \r\n  !  ',
          Whitespace.collapse,
        ),
        equals('Hello World !'),
      );
    });
  });
}
