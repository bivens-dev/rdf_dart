import 'dart:convert';
import 'dart:typed_data';

import 'package:intl/locale.dart';
import 'package:rdf_dart/rdf_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Literal', () {
    group('Creation', () {
      group('XML Schema Datatypes', () {
        group('language', () {
          group('with valid data', () {
            test('language tag with private extensions', () {
              final literal = Literal(
                'de-Latn-DE-1996-x-private-test',
                XSD.language,
              );
              expect(literal.lexicalForm, 'de-Latn-DE-1996-x-private-test');
              expect(literal.datatype, XSD.language);
              expect(
                literal.value,
                Locale.parse('de-Latn-DE-1996-x-private-test'),
              );
            });

            test('language tag with multiple variants', () {
              final literal = Literal(
                'sl-Latn-IT-rozaj-nedis-1996',
                XSD.language,
              );
              expect(literal.lexicalForm, 'sl-Latn-IT-rozaj-nedis-1996');
              expect(
                literal.getCanonicalLexicalForm(),
                'sl-Latn-IT-1996-nedis-rozaj',
              );
              expect(literal.datatype, XSD.language);
              expect(
                literal.value,
                Locale.parse('sl-Latn-IT-rozaj-nedis-1996'),
              );
            });

            test('simple language tag', () {
              final literal = Literal('en', XSD.language);
              expect(literal.lexicalForm, 'en');
              expect(literal.datatype, XSD.language);
              expect(literal.value, Locale.parse('en'));
            });

            test('language tag with country', () {
              final literal = Literal('en-AU', XSD.language);
              expect(literal.lexicalForm, 'en-AU');
              expect(literal.datatype, XSD.language);
              expect(literal.value, Locale.parse('en-AU'));
            });
          });

          group('with invalid data', () {
            test('cantbethislong is not a valid value', () {
              expect(
                () => Literal('cantbethislong', XSD.language),
                throwsA(isA<InvalidLexicalFormException>()),
              );
            });

            test('does not accept empty extensions', () {
              expect(
                () => Literal('ja-t-i-ami', XSD.language),
                throwsA(isA<InvalidLexicalFormException>()),
              );
            });
          });
        });

        group('boolean', () {
          group('using valid data', () {
            test('true is a valid boolean data type', () {
              final literal = Literal('true', XSD.boolean);
              expect(literal.value, true);
            });

            test('1 is a valid boolean data type', () {
              final literal = Literal('1', XSD.boolean);
              expect(literal.value, true);
            });

            test('false is a valid boolean data type', () {
              final literal = Literal('false', XSD.boolean);
              expect(literal.value, false);
            });

            test('0 is a valid boolean data type', () {
              final literal = Literal('0', XSD.boolean);
              expect(literal.value, false);
            });
          });

          group('serializing', () {
            test('false is serialized as correctly', () {
              final literal = Literal('0', XSD.boolean);
              expect(literal.lexicalForm, '0');
              expect(literal.getCanonicalLexicalForm(), 'false');
            });

            test('true is serialized as correctly', () {
              final literal = Literal('1', XSD.boolean);
              expect(literal.lexicalForm, '1');
              expect(literal.getCanonicalLexicalForm(), 'true');
            });
          });

          group('using invalid data', () {
            test('TRUE is not a valid boolean data type', () {
              expect(
                () => Literal('TRUE', XSD.boolean),
                throwsA(isA<InvalidLexicalFormException>()),
              );
            });

            test('FALSE is not a valid boolean data type', () {
              expect(
                () => Literal('FALSE', XSD.boolean),
                throwsA(isA<InvalidLexicalFormException>()),
              );
            });

            test('3 is not a valid boolean data type', () {
              expect(
                () => Literal('3', XSD.boolean),
                throwsA(isA<InvalidLexicalFormException>()),
              );
            });

            test(
              'valid numbers with leading symbols are not valid boolean data type',
              () {
                expect(
                  () => Literal('-0', XSD.boolean),
                  throwsA(isA<InvalidLexicalFormException>()),
                );
                expect(
                  () => Literal('-1', XSD.boolean),
                  throwsA(isA<InvalidLexicalFormException>()),
                );
                expect(
                  () => Literal('+0', XSD.boolean),
                  throwsA(isA<InvalidLexicalFormException>()),
                );
                expect(
                  () => Literal('+1', XSD.boolean),
                  throwsA(isA<InvalidLexicalFormException>()),
                );
              },
            );

            test('decimal values are not a valid boolean data type', () {
              expect(
                () => Literal('1.0', XSD.boolean),
                throwsA(isA<InvalidLexicalFormException>()),
              );
              expect(
                () => Literal('0.0', XSD.boolean),
                throwsA(isA<InvalidLexicalFormException>()),
              );
            });
          });
        });

        group('float', () {
          group('using valid data', () {
            test('with exponents in non-canonical form', () {
              final literal = Literal('-3E2', XSD.float);
              expect(literal.lexicalForm, '-3E2');
              expect(literal.getCanonicalLexicalForm(), '-3.0E2');
              expect(literal.datatype, XSD.float);
              expect(literal.language, isNull);
              expect(literal.value, -3.0E2);
            });

            test('exponents with decimals', () {
              final literal = Literal('4268.22752E11', XSD.float);
              expect(literal.lexicalForm, '4268.22752E11');
              expect(literal.getCanonicalLexicalForm(), '4.26822752E14');
              expect(literal.datatype, XSD.float);
              expect(literal.language, isNull);
              expect(literal.value, 4268.22752E11);
              expect(literal.value, 4.26822752E14);
            });

            test('exponents with decimals and a leading plus sign', () {
              final literal = Literal('+24.3e-3', XSD.float);
              expect(literal.lexicalForm, '+24.3e-3');
              expect(literal.getCanonicalLexicalForm(), '2.43E-2');
              expect(literal.datatype, XSD.float);
              expect(literal.language, isNull);
              expect(literal.value, 24.3e-3);
              expect(literal.value, 2.43E-2);
            });

            test('As an integer', () {
              final literal = Literal('12', XSD.float);
              expect(literal.lexicalForm, '12');
              expect(literal.getCanonicalLexicalForm(), '1.2E1');
              expect(literal.datatype, XSD.float);
              expect(literal.language, isNull);
              expect(literal.value, 12);
              expect(literal.value, 1.2E1);
            });

            test('With a decimal point and a leading plus sign', () {
              final literal = Literal('+3.5', XSD.float);
              expect(literal.lexicalForm, '+3.5');
              expect(literal.getCanonicalLexicalForm(), '3.5E0');
              expect(literal.datatype, XSD.float);
              expect(literal.language, isNull);
              expect(literal.value, 3.5);
              expect(literal.value, 3.5E0);
            });

            test('negative infinity', () {
              final literal = Literal('-INF', XSD.float);
              expect(literal.lexicalForm, '-INF');
              expect(literal.datatype, XSD.float);
              expect(literal.language, isNull);
              expect(literal.value, double.negativeInfinity);
            });

            test('negative zero', () {
              final literal = Literal('-0', XSD.float);
              expect(literal.lexicalForm, '-0');
              expect(literal.getCanonicalLexicalForm(), '-0.0E0');
              expect(literal.datatype, XSD.float);
              expect(literal.language, isNull);
              expect(literal.value, 0);
            });

            test('not a number', () {
              final literal = Literal('NaN', XSD.float);
              expect(literal.lexicalForm, 'NaN');
              expect(literal.datatype, XSD.float);
              expect(literal.language, isNull);
            });
          });
        });

        group('anyURI', () {
          group('using valid data', () {
            test('A URL', () {
              final literal = Literal('https://example.com', XSD.anyURI);
              expect(literal.lexicalForm, 'https://example.com');
              expect(literal.datatype, XSD.anyURI);
              expect(literal.language, isNull);
              expect(literal.value, Uri.tryParse('https://example.com'));
            });

            test('absolute URI', () {
              final literal = Literal('mailto:hello@world.com', XSD.anyURI);
              expect(literal.lexicalForm, 'mailto:hello@world.com');
              expect(literal.datatype, XSD.anyURI);
              expect(literal.language, isNull);
              expect(literal.value, Uri.tryParse('mailto:hello@world.com'));
            });

            test('relative URI containing escaped non-ASCII character', () {
              final literal = Literal('../%C3%A9dict.html', XSD.anyURI);
              expect(literal.lexicalForm, '../%C3%A9dict.html');
              expect(literal.datatype, XSD.anyURI);
              expect(literal.language, isNull);
              expect(literal.value, Uri.tryParse('../%C3%A9dict.html'));
            });

            test('URI with fragment identifier', () {
              final literal = Literal(
                'https://www.example.com/test.html#works',
                XSD.anyURI,
              );
              expect(
                literal.lexicalForm,
                'https://www.example.com/test.html#works',
              );
              expect(literal.datatype, XSD.anyURI);
              expect(literal.language, isNull);
              expect(
                literal.value,
                Uri.tryParse('https://www.example.com/test.html#works'),
              );
            });

            test('URN value', () {
              final literal = Literal('urn:example:org', XSD.anyURI);
              expect(literal.lexicalForm, 'urn:example:org');
              expect(literal.datatype, XSD.anyURI);
              expect(literal.language, isNull);
              expect(literal.value, Uri.tryParse('urn:example:org'));
            });
          });
        });

        group('double', () {
          group('using valid data', () {
            test('with decimal places', () {
              final literal = Literal('3.14', XSD.double);
              expect(literal.lexicalForm, '3.14');
              expect(literal.getCanonicalLexicalForm(), '3.14E0');
              expect(literal.datatype, XSD.double);
              expect(literal.language, isNull);
              expect(literal.value, 3.14);
            });

            test('values without decimal places are normalized', () {
              final literal = Literal('1', XSD.double);
              expect(literal.lexicalForm, '1');
              expect(literal.getCanonicalLexicalForm(), '1.0E0');
              expect(literal.datatype, XSD.double);
              expect(literal.language, isNull);
              expect(literal.value, 1.0);
            });

            test('values with lowercase e exponents are normalized', () {
              final literal = Literal('1.0e+1', XSD.double);
              expect(literal.lexicalForm, '1.0e+1');
              expect(literal.getCanonicalLexicalForm(), '1.0E1');
              expect(literal.datatype, XSD.double);
              expect(literal.language, isNull);
              expect(literal.value, 1.0E1);
            });

            test('INF is a valid value', () {
              final literal = Literal('INF', XSD.double);
              expect(literal.lexicalForm, 'INF');
              expect(literal.datatype, XSD.double);
              expect(literal.language, isNull);
              expect(literal.value, double.infinity);
            });

            test('-INF is a valid value', () {
              final literal = Literal('-INF', XSD.double);
              expect(literal.lexicalForm, '-INF');
              expect(literal.datatype, XSD.double);
              expect(literal.language, isNull);
              expect(literal.value, double.negativeInfinity);
            });

            test('inf is a valid value', () {
              final literal = Literal('inf', XSD.double);
              expect(literal.lexicalForm, 'inf');
              expect(literal.getCanonicalLexicalForm(), 'INF');
              expect(literal.datatype, XSD.double);
              expect(literal.language, isNull);
              expect(literal.value, double.infinity);
            });

            test('values with exponents are normalized', () {
              final literal = Literal('1.E-8', XSD.double);
              expect(literal.lexicalForm, '1.E-8');
              expect(literal.getCanonicalLexicalForm(), '1.0E-8');
              expect(literal.datatype, XSD.double);
              expect(literal.language, isNull);
              expect(literal.value, 1.0E-8);
            });

            test('leading zeros are normalized', () {
              final literal = Literal('01', XSD.double);
              expect(literal.lexicalForm, '01');
              expect(literal.getCanonicalLexicalForm(), '1.0E0');
              expect(literal.datatype, XSD.double);
              expect(literal.language, isNull);
              expect(literal.value, 1);
            });

            test('negative numbers without decimal places', () {
              final literal = Literal('-1', XSD.double);
              expect(literal.lexicalForm, '-1');
              expect(literal.getCanonicalLexicalForm(), '-1.0E0');
              expect(literal.datatype, XSD.double);
              expect(literal.language, isNull);
              expect(literal.value, -1);
            });

            test('trailing decimal points are normalized', () {
              final literal = Literal('1.', XSD.double);
              expect(literal.lexicalForm, '1.');
              expect(literal.getCanonicalLexicalForm(), '1.0E0');
              expect(literal.datatype, XSD.double);
              expect(literal.language, isNull);
              expect(literal.value, 1.0);
            });

            test('redundant decimal points are normalized', () {
              final literal = Literal('1.00', XSD.double);
              expect(literal.lexicalForm, '1.00');
              expect(literal.getCanonicalLexicalForm(), '1.0E0');
              expect(literal.datatype, XSD.double);
              expect(literal.language, isNull);
              expect(literal.value, 1);
            });

            test(
              'redundant zeros combined with the plus sign are normalized',
              () {
                final literal = Literal('+001.00', XSD.double);
                expect(literal.lexicalForm, '+001.00');
                expect(literal.getCanonicalLexicalForm(), '1.0E0');
                expect(literal.datatype, XSD.double);
                expect(literal.language, isNull);
                expect(literal.value, 1);
              },
            );

            test('precision with 10 decimal places works as expected', () {
              final literal = Literal('2.234000005', XSD.double);
              expect(literal.lexicalForm, '2.234000005');
              expect(literal.getCanonicalLexicalForm(), '2.234000005E0');
              expect(literal.datatype, XSD.double);
              expect(literal.language, isNull);
              expect(literal.value, 2.234000005);
            });

            test('precision with 16 decimal places works as expected', () {
              final literal = Literal('2.2340000000000005', XSD.double);
              expect(literal.lexicalForm, '2.2340000000000005');
              // TODO: Investigate broken test
              // expect(literal.getCanonicalLexicalForm(), '2.2340000000000005E0');
              expect(literal.datatype, XSD.double);
              expect(literal.language, isNull);
              expect(literal.value, 2.2340000000000005);
            });

            test('precision with 17 decimal places is rounded', () {
              final literal = Literal('2.23400000000000005', XSD.double);
              expect(literal.lexicalForm, '2.23400000000000005');
              expect(literal.getCanonicalLexicalForm(), '2.234E0');
              expect(literal.datatype, XSD.double);
              expect(literal.language, isNull);
              expect(literal.value, 2.234);
            });

            test('number starting with a decimal point is valid', () {
              final literal = Literal('.2', XSD.double);
              expect(literal.lexicalForm, '.2');
              expect(literal.getCanonicalLexicalForm(), '2.0E-1');
              expect(literal.datatype, XSD.double);
              expect(literal.language, isNull);
              expect(literal.value, 0.2);
            });

            test('rounding is capped at 16 decimal places', () {
              final literal = Literal(
                '1.2345678901234567890123457890',
                XSD.double,
              );
              expect(literal.lexicalForm, '1.2345678901234567890123457890');
              expect(literal.getCanonicalLexicalForm(), '1.2345678901234567E0');
              expect(literal.datatype, XSD.double);
              expect(literal.language, isNull);
              expect(literal.value, 1.2345678901234567);
            });

            test(
              'redundant zeros combined with the minus sign are normalized',
              () {
                final literal = Literal('-001.00', XSD.double);
                expect(literal.lexicalForm, '-001.00');
                expect(literal.getCanonicalLexicalForm(), '-1.0E0');
                expect(literal.datatype, XSD.double);
                expect(literal.language, isNull);
                expect(literal.value, -1);
              },
            );
          });

          group('using invalid data', () {
            test('non numerical figures are not valid double data types', () {
              expect(
                () => Literal('abc', XSD.double),
                throwsA(isA<InvalidLexicalFormException>()),
              );
            });

            test('Only a +/- sign is not a valid double data type', () {
              expect(
                () => Literal('+', XSD.double),
                throwsA(isA<InvalidLexicalFormException>()),
              );
              expect(
                () => Literal('-', XSD.double),
                throwsA(isA<InvalidLexicalFormException>()),
              );
            });

            test('Multiple decimal points are not valid', () {
              expect(
                () => Literal('1.2.3', XSD.double),
                throwsA(isA<InvalidLexicalFormException>()),
              );
            });

            test('Numbers with spaces are not valid', () {
              expect(
                () => Literal('1 2 3', XSD.double),
                throwsA(isA<InvalidLexicalFormException>()),
              );
            });
          });
        });

        group('unsigned byte', () {
          group('with valid data', () {
            test('0 is a valid value', () {
              final literal = Literal('0', XSD.unsignedByte);
              expect(literal.lexicalForm, '0');
              expect(literal.language, isNull);
              expect(literal.value, 0);
            });

            test('255 is a valid value', () {
              final literal = Literal('255', XSD.unsignedByte);
              expect(literal.lexicalForm, '255');
              expect(literal.language, isNull);
              expect(literal.value, 255);
            });
          });

          group('with invalid data', () {
            test('256 is not a valid value', () {
              expect(() => Literal('256', XSD.unsignedByte), throwsRangeError);
            });
          });
        });
        group('byte types', () {
          group('with valid data', () {
            test('0 is a valid value', () {
              final literal = Literal('0', XSD.byte);
              expect(literal.lexicalForm, '0');
              expect(literal.language, isNull);
              expect(literal.value, 0);
            });

            test('-1 is a valid value', () {
              final literal = Literal('-1', XSD.byte);
              expect(literal.lexicalForm, '-1');
              expect(literal.language, isNull);
              expect(literal.value, -1);
            });

            test('-128 is a valid value', () {
              final literal = Literal('-128', XSD.byte);
              expect(literal.lexicalForm, '-128');
              expect(literal.language, isNull);
              expect(literal.value, -128);
            });

            test('127 is a valid value', () {
              final literal = Literal('127', XSD.byte);
              expect(literal.lexicalForm, '127');
              expect(literal.language, isNull);
              expect(literal.value, 127);
            });

            test('valid values with a leading + are normalised', () {
              final literal = Literal('+127', XSD.byte);
              expect(literal.lexicalForm, '+127');
              expect(literal.getCanonicalLexicalForm(), '127');
              expect(literal.language, isNull);
              expect(literal.value, 127);
            });
          });

          group('with invalid data', () {
            test('128 is not a valid value', () {
              expect(() => Literal('128', XSD.byte), throwsRangeError);
            });

            test('-129 is not a valid value', () {
              expect(() => Literal('-129', XSD.byte), throwsRangeError);
            });

            test('+-0 is not a valid value', () {
              expect(
                () => Literal('+-0', XSD.byte),
                throwsA(isA<InvalidLexicalFormException>()),
              );
            });

            test('non numerical characters are not a valid value', () {
              expect(
                () => Literal('abc', XSD.byte),
                throwsA(isA<InvalidLexicalFormException>()),
              );
            });
          });
        });

        group('unsigned short', () {
          group('with valid data', () {
            test('0 is a valid value', () {
              final literal = Literal('0', XSD.unsignedShort);
              expect(literal.lexicalForm, '0');
              expect(literal.language, isNull);
              expect(literal.value, 0);
            });

            test('65535 is a valid value', () {
              final literal = Literal('65535', XSD.unsignedShort);
              expect(literal.lexicalForm, '65535');
              expect(literal.language, isNull);
              expect(literal.value, 65535);
            });
          });

          group('with invalid data', () {
            test('65536 is not a valid value', () {
              expect(
                () => Literal('65536', XSD.unsignedShort),
                throwsRangeError,
              );
            });
          });
        });

        group('short', () {
          group('with valid data', () {
            test('0 is a valid value', () {
              final literal = Literal('0', XSD.short);
              expect(literal.lexicalForm, '0');
              expect(literal.language, isNull);
              expect(literal.value, 0);
            });

            test('32767 is a valid value', () {
              final literal = Literal('32767', XSD.short);
              expect(literal.lexicalForm, '32767');
              expect(literal.language, isNull);
              expect(literal.value, 32767);
            });

            test('-32768 is a valid value', () {
              final literal = Literal('-32768', XSD.short);
              expect(literal.lexicalForm, '-32768');
              expect(literal.language, isNull);
              expect(literal.value, -32768);
            });
          });

          group('with invalid data', () {
            test('32768 is not a valid value', () {
              expect(() => Literal('32768', XSD.short), throwsRangeError);
            });

            test('-32769 is not a valid value', () {
              expect(() => Literal('-32769', XSD.short), throwsRangeError);
            });
          });
        });

        group('unsigned int', () {
          group('with valid data', () {
            test('0 is a valid value', () {
              final literal = Literal('0', XSD.unsignedInt);
              expect(literal.lexicalForm, '0');
              expect(literal.language, isNull);
              expect(literal.value, 0);
            });

            test('4294967295 is a valid value', () {
              final literal = Literal('4294967295', XSD.unsignedInt);
              expect(literal.lexicalForm, '4294967295');
              expect(literal.language, isNull);
              expect(literal.value, 4294967295);
            });
          });

          group('with invalid data', () {
            test('65536 is not a valid value', () {
              expect(
                () => Literal('4294967296', XSD.unsignedInt),
                throwsRangeError,
              );
            });
          });
        });

        group('int', () {
          group('with valid data', () {
            test('0 is a valid value', () {
              final literal = Literal('0', XSD.int);
              expect(literal.lexicalForm, '0');
              expect(literal.language, isNull);
              expect(literal.value, 0);
            });

            test('2147483647 is a valid value', () {
              final literal = Literal('2147483647', XSD.int);
              expect(literal.lexicalForm, '2147483647');
              expect(literal.language, isNull);
              expect(literal.value, 2147483647);
            });

            test('-2147483648 is a valid value', () {
              final literal = Literal('-2147483648', XSD.int);
              expect(literal.lexicalForm, '-2147483648');
              expect(literal.language, isNull);
              expect(literal.value, -2147483648);
            });
          });

          group('with invalid data', () {
            test('2147483648 is not a valid value', () {
              expect(() => Literal('2147483648', XSD.int), throwsRangeError);
            });

            test('-2147483649 is not a valid value', () {
              expect(() => Literal('-2147483649', XSD.short), throwsRangeError);
            });
          });
        });

        group('base64Binary', () {
          group('with valid data', () {
            test('it decodes the data correctly', () {
              final literal = Literal('SGVsbG8gV29ybGQ=', XSD.base64Binary);

              expect(literal.lexicalForm, 'SGVsbG8gV29ybGQ=');
              expect(literal.language, isNull);
              expect(utf8.decode(literal.value as Uint8List), 'Hello World');
            });
          });

          group('with invalid data', () {
            test('rejects invalid characters', () {
              expect(
                () => Literal('^not a valid string^', XSD.base64Binary),
                throwsA(isA<InvalidLexicalFormException>()),
              );
            });
          });
        });

        group('hexBinary', () {
          group('with valid data', () {
            test('it decodes the data correctly with lowercase hex', () {
              final literal = Literal('48656c6c6f20576f726c64', XSD.hexBinary);

              expect(literal.lexicalForm, '48656c6c6f20576f726c64');
              expect(literal.language, isNull);
              expect(utf8.decode(literal.value as Uint8List), 'Hello World');
            });

            test('it decodes the data correctly with uppercase hex', () {
              final literal = Literal('48656C6C6F20576F726C64', XSD.hexBinary);

              expect(literal.lexicalForm, '48656C6C6F20576F726C64');
              expect(
                literal.getCanonicalLexicalForm(),
                '48656c6c6f20576f726c64',
              );
              expect(literal.language, isNull);
              expect(utf8.decode(literal.value as Uint8List), 'Hello World');
            });

            test('it decodes the data correctly with mixed case hex', () {
              final literal = Literal('48656c6C6f20576F726C64', XSD.hexBinary);

              expect(literal.lexicalForm, '48656c6C6f20576F726C64');
              expect(
                literal.getCanonicalLexicalForm(),
                '48656c6c6f20576f726c64',
              );
              expect(literal.language, isNull);
              expect(utf8.decode(literal.value as Uint8List), 'Hello World');
            });
          });

          group('with invalid data', () {
            test('rejects invalid characters', () {
              expect(
                () => Literal('^not a valid hex string^', XSD.hexBinary),
                throwsA(isA<InvalidLexicalFormException>()),
              );
            });
          });
        });

        group('langString', () {
          final langStringIri = RDF.langString;

          group('with valid data', () {
            test('with a simple language tag', () {
              final literal = Literal('bonjour', langStringIri, 'fr');
              expect(literal.lexicalForm, 'bonjour');
              expect(literal.datatype, langStringIri);
              expect(literal.language, Locale.parse('fr'));
              expect(literal.value, 'bonjour');
            });

            test('with a language and country tag', () {
              final literal = Literal('tudo bem', langStringIri, 'pt-PT');
              expect(literal.lexicalForm, 'tudo bem');
              expect(literal.datatype, langStringIri);
              expect(literal.language, Locale.parse('pt-PT'));
              expect(literal.value, 'tudo bem');
            });

            test('language tags are case insensitive', () {
              final literal1 = Literal("G'day Mate", langStringIri, 'en-AU');
              final literal2 = Literal("G'day Mate", langStringIri, 'en-au');
              expect(literal1.language, literal2.language);
              expect(
                literal1.language.toString(),
                literal2.language.toString(),
              );
            });
          });

          group('with invalid data', () {
            test('with an invalid language tag', () {
              expect(
                () => Literal(
                  'hello world',
                  langStringIri,
                  'invalid_language_tag',
                ),
                throwsA(isA<InvalidLanguageTagException>()),
              );
            });

            test('with a language tag but the wrong data type', () {
              expect(
                () => Literal("g'day world", XSD.string, 'en-AU'),
                throwsA(isA<LiteralConstraintException>()),
              );
            });
          });
        });

        group('cross cutting concerns', () {
          test("numbers don't accept blank strings", () {
            expect(
              () => Literal('', XSD.unsignedByte),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('', XSD.byte),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('', XSD.unsignedInt),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('', XSD.int),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('', XSD.short),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('', XSD.unsignedShort),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('', XSD.integer),
              throwsA(isA<InvalidLexicalFormException>()),
            );
          });

          test("numbers don't accept only +/- signs", () {
            expect(
              () => Literal('-', XSD.unsignedByte),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('+', XSD.unsignedByte),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('-', XSD.byte),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('+', XSD.byte),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('-', XSD.unsignedInt),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('+', XSD.unsignedInt),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('-', XSD.int),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('+', XSD.int),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('-', XSD.unsignedShort),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('+', XSD.unsignedShort),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('-', XSD.short),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('+', XSD.short),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('-', XSD.integer),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('+', XSD.integer),
              throwsA(isA<InvalidLexicalFormException>()),
            );
          });

          test("numbers don't accept letters", () {
            expect(
              () => Literal('one', XSD.unsignedByte),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('one', XSD.unsignedByte),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('one', XSD.byte),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('one', XSD.byte),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('one', XSD.unsignedInt),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('one', XSD.unsignedInt),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('one', XSD.int),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('one', XSD.int),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('one', XSD.unsignedShort),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('one', XSD.unsignedShort),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('one', XSD.short),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('one', XSD.short),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('one', XSD.integer),
              throwsA(isA<InvalidLexicalFormException>()),
            );
            expect(
              () => Literal('one', XSD.integer),
              throwsA(isA<InvalidLexicalFormException>()),
            );
          });
        });

        group('nonNegativeInteger', () {
          group('with valid data', () {
            test('0 is a valid value', () {
              final literal = Literal('0', XSD.nonNegativeInteger);
              expect(literal.lexicalForm, '0');
              expect(literal.language, isNull);
              expect(literal.value, 0);
            });

            test('1 is a valid value', () {
              final literal = Literal('1', XSD.nonNegativeInteger);
              expect(literal.lexicalForm, '1');
              expect(literal.language, isNull);
              expect(literal.value, 1);
            });

            test('value with leading space is a valid value', () {
              final literal = Literal(' 1', XSD.nonNegativeInteger);
              expect(literal.getCanonicalLexicalForm(), '1');
              expect(literal.lexicalForm, ' 1');
              expect(literal.language, isNull);
              expect(literal.value, 1);
            });

            test('value with trailing space is a valid value', () {
              final literal = Literal('1 ', XSD.nonNegativeInteger);
              expect(literal.lexicalForm, '1 ');
              expect(literal.getCanonicalLexicalForm(), '1');
              expect(literal.language, isNull);
              expect(literal.value, 1);
            });
          });

          group('with invalid data', () {
            test('-1 is not a valid value', () {
              expect(
                () => Literal('-1', XSD.nonNegativeInteger),
                throwsRangeError,
              );
            });

            test('1.5 is not a valid value', () {
              expect(
                () => Literal('1.5', XSD.nonNegativeInteger),
                throwsA(isA<InvalidLexicalFormException>()),
              );
            });
          });
        });

        group('negativeInteger', () {
          group('with valid data', () {
            test('-1 is a valid value', () {
              final literal = Literal('-1', XSD.negativeInteger);
              expect(literal.lexicalForm, '-1');
              expect(literal.language, isNull);
              expect(literal.value, -1);
            });

            test('value with leading space is a valid value', () {
              final literal = Literal(' -1', XSD.negativeInteger);
              expect(literal.lexicalForm, ' -1');
              expect(literal.getCanonicalLexicalForm(), '-1');
              expect(literal.language, isNull);
              expect(literal.value, -1);
            });

            test('value with trailing space is a valid value', () {
              final literal = Literal('-1 ', XSD.negativeInteger);
              expect(literal.lexicalForm, '-1 ');
              expect(literal.getCanonicalLexicalForm(), '-1');
              expect(literal.language, isNull);
              expect(literal.value, -1);
            });
          });

          group('with invalid data', () {
            test('0 is not a valid value', () {
              expect(() => Literal('0', XSD.negativeInteger), throwsRangeError);
            });

            test('-1.5 is not a valid value', () {
              expect(
                () => Literal('-1.5', XSD.negativeInteger),
                throwsA(isA<InvalidLexicalFormException>()),
              );
            });

            test('-0 is not a valid value', () {
              expect(
                () => Literal('-0', XSD.negativeInteger),
                throwsRangeError,
              );
            });
          });
        });

        group('nonPositiveInteger', () {
          group('with valid data', () {
            test('0 is a valid value', () {
              final literal = Literal('0', XSD.nonPositiveInteger);
              expect(literal.lexicalForm, '0');
              expect(literal.language, isNull);
              expect(literal.value, 0);
            });

            test('-1 is a valid value', () {
              final literal = Literal('-1', XSD.nonPositiveInteger);
              expect(literal.lexicalForm, '-1');
              expect(literal.language, isNull);
              expect(literal.value, -1);
            });

            test('value with leading space is a valid value', () {
              final literal = Literal(' -1', XSD.nonPositiveInteger);
              expect(literal.lexicalForm, ' -1');
              expect(literal.getCanonicalLexicalForm(), '-1');
              expect(literal.language, isNull);
              expect(literal.value, -1);
            });

            test('value with trailing space is a valid value', () {
              final literal = Literal('-1 ', XSD.nonPositiveInteger);
              expect(literal.lexicalForm, '-1 ');
              expect(literal.getCanonicalLexicalForm(), '-1');
              expect(literal.language, isNull);
              expect(literal.value, -1);
            });
          });

          group('with invalid data', () {
            test('1 is not a valid value', () {
              expect(
                () => Literal('1', XSD.nonPositiveInteger),
                throwsRangeError,
              );
            });

            test('-1.5 is not a valid value', () {
              expect(
                () => Literal('-1.5', XSD.nonPositiveInteger),
                throwsA(isA<InvalidLexicalFormException>()),
              );
            });
          });
        });
      });

      test('with string datatype', () {
        final literal = Literal('hello', XSD.string);
        expect(literal.lexicalForm, 'hello');
        expect(literal.datatype, XSD.string);
        expect(literal.language, isNull);
        expect(literal.value, 'hello');
      });

      test('with integer datatype', () {
        final literal = Literal('42', XSD.integer);
        expect(literal.lexicalForm, '42');
        expect(literal.datatype, XSD.integer);
        expect(literal.language, isNull);
        expect(literal.value, BigInt.from(42));
      });

      test('with double datatype', () {
        final literal = Literal('3.14', XSD.double);
        expect(literal.lexicalForm, '3.14');
        expect(literal.getCanonicalLexicalForm(), '3.14E0');
        expect(literal.datatype, XSD.double);
        expect(literal.language, isNull);
        expect(literal.value, 3.14);
      });

      test('with dateTime datatype', () {
        final now = DateTime.utc(2025, 03, 12, 23, 30, 38, 917614);
        final literal = Literal(now.toIso8601String(), XSD.dateTime);
        expect(literal.lexicalForm, now.toIso8601String());
        expect(literal.datatype, XSD.dateTime);
        expect(literal.language, isNull);
        expect(
          (literal.value as DateTime).toIso8601String(),
          now.toIso8601String(),
        );
      });

      test('with boolean datatype', () {
        final literal = Literal('true', XSD.boolean);
        expect(literal.lexicalForm, 'true');
        expect(literal.datatype, XSD.boolean);
        expect(literal.language, isNull);
        expect(literal.value, true);
      });
    });

    group('Type checking', () {
      test('isIRI is false', () {
        final literal = Literal('hello', XSD.string);
        expect(literal.isIRI, false);
      });

      test('isBlankNode is false', () {
        final literal = Literal('hello', XSD.string);
        expect(literal.isBlankNode, false);
      });

      test('isLiteral is true', () {
        final literal = Literal('hello', XSD.string);
        expect(literal.isLiteral, true);
      });
    });

    group('TermType', () {
      test('termType is literal', () {
        final literal = Literal('hello', XSD.string);
        expect(literal.termType, TermType.literal);
      });
    });

    group('toString', () {
      test('string literal without language tag', () {
        final literal = Literal('hello', XSD.string);
        expect(literal.toString(), '"hello"');
      });

      test('string literal with language tag', () {
        final literal = Literal('bonjour', RDF.langString, 'fr');
        expect(literal.toString(), '"bonjour"@fr');
      });

      test('integer literal', () {
        final literal = Literal('42', XSD.integer);
        expect(
          literal.toString(),
          '"42"^^<http://www.w3.org/2001/XMLSchema#integer>',
        );
      });
      test('boolean literal', () {
        final literal = Literal('true', XSD.boolean);
        expect(
          literal.toString(),
          '"true"^^<http://www.w3.org/2001/XMLSchema#boolean>',
        );
      });
      test('double literal', () {
        final literal = Literal('3.14', XSD.double);
        expect(
          literal.toString(),
          '"3.14"^^<http://www.w3.org/2001/XMLSchema#double>',
        );
      });
      test('date time literal', () {
        final now = DateTime.utc(2025, 03, 12, 23, 30, 38, 917614);
        final literal = Literal(now.toIso8601String(), XSD.dateTime);
        expect(
          literal.toString(),
          '"${now.toIso8601String()}"^^<http://www.w3.org/2001/XMLSchema#dateTime>',
        );
      });
    });
    group('toLexicalForm', () {
      test('string', () {
        final literal = Literal('hello', XSD.string);
        expect(literal.lexicalForm, 'hello');
        expect(literal.getCanonicalLexicalForm(), 'hello');
      });
      test('integer', () {
        final literal = Literal('42', XSD.integer);
        expect(literal.lexicalForm, '42');
        expect(literal.getCanonicalLexicalForm(), '42');
      });
      test('double', () {
        final literal = Literal('3.14', XSD.double);
        expect(literal.lexicalForm, '3.14');
        expect(literal.getCanonicalLexicalForm(), '3.14E0');
      });
      test('date time', () {
        final now = DateTime.utc(2025, 03, 12, 23, 30, 38, 917614);
        final literal = Literal(now.toIso8601String(), XSD.dateTime);
        expect(literal.lexicalForm, now.toIso8601String());
        expect(literal.getCanonicalLexicalForm(), now.toIso8601String());
      });
      test('boolean', () {
        final literal = Literal('true', XSD.boolean);
        expect(literal.lexicalForm, 'true');
        expect(literal.getCanonicalLexicalForm(), 'true');
      });
    });

    group('Equality', () {
      test('equal literals', () {
        final literal1 = Literal('hello', XSD.string);
        final literal2 = Literal('hello', XSD.string);
        expect(literal1 == literal2, true);
      });

      test('different lexical forms', () {
        final literal1 = Literal('hello', XSD.string);
        final literal2 = Literal('world', XSD.string);
        expect(literal1 == literal2, false);
      });

      test('different datatypes', () {
        final literal1 = Literal('42', XSD.integer);
        final literal2 = Literal('42', XSD.string);
        expect(literal1 == literal2, false);
      });

      test('different language tags', () {
        final literal1 = Literal('bonjour', RDF.langString, 'fr');
        final literal2 = Literal('bonjour', RDF.langString, 'en');
        expect(literal1 == literal2, false);
      });

      test('one with language tag, one without', () {
        final literal1 = Literal('hello', XSD.string);
        final literal2 = Literal('hello', RDF.langString, 'fr');
        expect(literal1 == literal2, false);
      });
    });

    group('HashCode', () {
      test('equal literals have same hashCode', () {
        final literal1 = Literal('hello', XSD.string);
        final literal2 = Literal('hello', XSD.string);
        expect(literal1.hashCode == literal2.hashCode, true);
      });

      test('different lexical forms have different hashCodes', () {
        final literal1 = Literal('hello', XSD.string);
        final literal2 = Literal('world', XSD.string);
        expect(literal1.hashCode == literal2.hashCode, false);
      });

      test('different datatypes have different hashCodes', () {
        final literal1 = Literal('42', XSD.integer);
        final literal2 = Literal('42', XSD.string);
        expect(literal1.hashCode == literal2.hashCode, false);
      });

      test('different language tags have different hashCodes', () {
        final literal1 = Literal('bonjour', RDF.langString, 'fr');
        final literal2 = Literal('bonjour', RDF.langString, 'en');
        expect(literal1.hashCode == literal2.hashCode, false);
      });

      test('one with language tag, one without have different hashCodes', () {
        final literal1 = Literal('hello', XSD.string);
        final literal2 = Literal('hello', RDF.langString, 'fr');
        expect(literal1.hashCode == literal2.hashCode, false);
      });
    });
  });
}
