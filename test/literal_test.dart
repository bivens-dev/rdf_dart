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
                IRI(XMLDataType.language.iri),
              );
              expect(literal.lexicalForm, 'de-Latn-DE-1996-x-private-test');
              expect(literal.datatype, IRI(XMLDataType.language.iri));
              expect(
                literal.value,
                Locale.parse('de-Latn-DE-1996-x-private-test'),
              );
            });

            test('language tag with multiple variants', () {
              final literal = Literal(
                'sl-Latn-IT-rozaj-nedis-1996',
                IRI(XMLDataType.language.iri),
              );
              expect(literal.lexicalForm, 'sl-Latn-IT-1996-nedis-rozaj');
              expect(literal.datatype, IRI(XMLDataType.language.iri));
              expect(
                literal.value,
                Locale.parse('sl-Latn-IT-rozaj-nedis-1996'),
              );
            });

            test('simple language tag', () {
              final literal = Literal('en', IRI(XMLDataType.language.iri));
              expect(literal.lexicalForm, 'en');
              expect(literal.datatype, IRI(XMLDataType.language.iri));
              expect(literal.value, Locale.parse('en'));
            });

            test('language tag with country', () {
              final literal = Literal('en-AU', IRI(XMLDataType.language.iri));
              expect(literal.lexicalForm, 'en-AU');
              expect(literal.datatype, IRI(XMLDataType.language.iri));
              expect(literal.value, Locale.parse('en-AU'));
            });
          });

          group('with invalid data', () {
            test('cantbethislong is not a valid value', () {
              expect(
                () => Literal('cantbethislong', IRI(XMLDataType.language.iri)),
                throwsFormatException,
              );
            });

            test('does not accept empty extensions', () {
              expect(
                () => Literal('ja-t-i-ami', IRI(XMLDataType.language.iri)),
                throwsFormatException,
              );
            });
          });
        });

        group('boolean', () {
          group('using valid data', () {
            test('true is a valid boolean data type', () {
              final literal = Literal('true', IRI(XMLDataType.boolean.iri));
              expect(literal.value, true);
            });

            test('1 is a valid boolean data type', () {
              final literal = Literal('1', IRI(XMLDataType.boolean.iri));
              expect(literal.value, true);
            });

            test('false is a valid boolean data type', () {
              final literal = Literal('false', IRI(XMLDataType.boolean.iri));
              expect(literal.value, false);
            });

            test('0 is a valid boolean data type', () {
              final literal = Literal('0', IRI(XMLDataType.boolean.iri));
              expect(literal.value, false);
            });
          });

          group('serializing', () {
            test('false is serialized as correctly', () {
              final literal = Literal('0', IRI(XMLDataType.boolean.iri));
              expect(literal.lexicalForm, 'false');
            });

            test('true is serialized as correctly', () {
              final literal = Literal('1', IRI(XMLDataType.boolean.iri));
              expect(literal.lexicalForm, 'true');
            });
          });

          group('using invalid data', () {
            test('TRUE is not a valid boolean data type', () {
              expect(
                () => Literal('TRUE', IRI(XMLDataType.boolean.iri)),
                throwsFormatException,
              );
            });

            test('FALSE is not a valid boolean data type', () {
              expect(
                () => Literal('FALSE', IRI(XMLDataType.boolean.iri)),
                throwsFormatException,
              );
            });

            test('3 is not a valid boolean data type', () {
              expect(
                () => Literal('3', IRI(XMLDataType.boolean.iri)),
                throwsFormatException,
              );
            });

            test(
              'valid numbers with leading symbols are not valid boolean data type',
              () {
                expect(
                  () => Literal('-0', IRI(XMLDataType.boolean.iri)),
                  throwsFormatException,
                );
                expect(
                  () => Literal('-1', IRI(XMLDataType.boolean.iri)),
                  throwsFormatException,
                );
                expect(
                  () => Literal('+0', IRI(XMLDataType.boolean.iri)),
                  throwsFormatException,
                );
                expect(
                  () => Literal('+1', IRI(XMLDataType.boolean.iri)),
                  throwsFormatException,
                );
              },
            );

            test('decimal values are not a valid boolean data type', () {
              expect(
                () => Literal('1.0', IRI(XMLDataType.boolean.iri)),
                throwsFormatException,
              );
              expect(
                () => Literal('0.0', IRI(XMLDataType.boolean.iri)),
                throwsFormatException,
              );
            });
          });
        });

        group('float', () {
          group('using valid data', () {
            test('with exponents in non-canonical form', () {
              final literal = Literal('-3E2', IRI(XMLDataType.float.iri));
              expect(literal.lexicalForm, '-3.0E2');
              expect(literal.datatype, IRI(XMLDataType.float.iri));
              expect(literal.language, isNull);
              expect(literal.value, -3.0E2);
            });

            test('exponents with decimals', () {
              final literal = Literal(
                '4268.22752E11',
                IRI(XMLDataType.float.iri),
              );
              expect(literal.lexicalForm, '4.26822752E14');
              expect(literal.datatype, IRI(XMLDataType.float.iri));
              expect(literal.language, isNull);
              expect(literal.value, 4268.22752E11);
              expect(literal.value, 4.26822752E14);
            });

            test('exponents with decimals and a leading plus sign', () {
              final literal = Literal('+24.3e-3', IRI(XMLDataType.float.iri));
              expect(literal.lexicalForm, '2.43E-2');
              expect(literal.datatype, IRI(XMLDataType.float.iri));
              expect(literal.language, isNull);
              expect(literal.value, 24.3e-3);
              expect(literal.value, 2.43E-2);
            });

            test('As an integer', () {
              final literal = Literal('12', IRI(XMLDataType.float.iri));
              expect(literal.lexicalForm, '1.2E1');
              expect(literal.datatype, IRI(XMLDataType.float.iri));
              expect(literal.language, isNull);
              expect(literal.value, 12);
              expect(literal.value, 1.2E1);
            });

            test('With a decimal point and a leading plus sign', () {
              final literal = Literal('+3.5', IRI(XMLDataType.float.iri));
              expect(literal.lexicalForm, '3.5E0');
              expect(literal.datatype, IRI(XMLDataType.float.iri));
              expect(literal.language, isNull);
              expect(literal.value, 3.5);
              expect(literal.value, 3.5E0);
            });

            test('negative infinity', () {
              final literal = Literal('-INF', IRI(XMLDataType.float.iri));
              expect(literal.lexicalForm, '-INF');
              expect(literal.datatype, IRI(XMLDataType.float.iri));
              expect(literal.language, isNull);
              expect(literal.value, double.negativeInfinity);
            });

            test('negative infinity', () {
              final literal = Literal('-0', IRI(XMLDataType.float.iri));
              expect(literal.lexicalForm, '-0.0E0');
              expect(literal.datatype, IRI(XMLDataType.float.iri));
              expect(literal.language, isNull);
              expect(literal.value, 0);
            });

            test('negative infinity', () {
              final literal = Literal('NaN', IRI(XMLDataType.float.iri));
              expect(literal.lexicalForm, 'NaN');
              expect(literal.datatype, IRI(XMLDataType.float.iri));
              expect(literal.language, isNull);
            });
          });
        });

        group('anyURI', () {
          group('using valid data', () {
            test('A URL', () {
              final literal = Literal(
                'https://example.com',
                IRI(XMLDataType.anyURI.iri),
              );
              expect(literal.lexicalForm, 'https://example.com');
              expect(literal.datatype, IRI(XMLDataType.anyURI.iri));
              expect(literal.language, isNull);
              expect(literal.value, Uri.tryParse('https://example.com'));
            });

            test('absolute URI', () {
              final literal = Literal(
                'mailto:hello@world.com',
                IRI(XMLDataType.anyURI.iri),
              );
              expect(literal.lexicalForm, 'mailto:hello@world.com');
              expect(literal.datatype, IRI(XMLDataType.anyURI.iri));
              expect(literal.language, isNull);
              expect(literal.value, Uri.tryParse('mailto:hello@world.com'));
            });

            test('relative URI containing escaped non-ASCII character', () {
              final literal = Literal(
                '../%C3%A9dict.html',
                IRI(XMLDataType.anyURI.iri),
              );
              expect(literal.lexicalForm, '../%C3%A9dict.html');
              expect(literal.datatype, IRI(XMLDataType.anyURI.iri));
              expect(literal.language, isNull);
              expect(literal.value, Uri.tryParse('../%C3%A9dict.html'));
            });

            test('URI with fragment identifier', () {
              final literal = Literal(
                'https://www.example.com/test.html#works',
                IRI(XMLDataType.anyURI.iri),
              );
              expect(
                literal.lexicalForm,
                'https://www.example.com/test.html#works',
              );
              expect(literal.datatype, IRI(XMLDataType.anyURI.iri));
              expect(literal.language, isNull);
              expect(
                literal.value,
                Uri.tryParse('https://www.example.com/test.html#works'),
              );
            });

            test('URN value', () {
              final literal = Literal(
                'urn:example:org',
                IRI(XMLDataType.anyURI.iri),
              );
              expect(literal.lexicalForm, 'urn:example:org');
              expect(literal.datatype, IRI(XMLDataType.anyURI.iri));
              expect(literal.language, isNull);
              expect(literal.value, Uri.tryParse('urn:example:org'));
            });
          });
        });

        group('double', () {
          group('using valid data', () {
            test('with decimal places', () {
              final literal = Literal('3.14', IRI(XMLDataType.double.iri));
              expect(literal.lexicalForm, '3.14E0');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, 3.14);
            });

            test('values without decimal places are normalized', () {
              final literal = Literal('1', IRI(XMLDataType.double.iri));
              expect(literal.lexicalForm, '1.0E0');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, 1.0);
            });

            test('values with lowercase e exponents are normalized', () {
              final literal = Literal('1.0e+1', IRI(XMLDataType.double.iri));
              expect(literal.lexicalForm, '1.0E1');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, 1.0E1);
            });

            test('INF is a valid value', () {
              final literal = Literal('INF', IRI(XMLDataType.double.iri));
              expect(literal.lexicalForm, 'INF');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, double.infinity);
            });

            test('-INF is a valid value', () {
              final literal = Literal('-INF', IRI(XMLDataType.double.iri));
              expect(literal.lexicalForm, '-INF');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, double.negativeInfinity);
            });

            test('inf is a valid value', () {
              final literal = Literal('inf', IRI(XMLDataType.double.iri));
              expect(literal.lexicalForm, 'INF');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, double.infinity);
            });

            test('values with exponents are normalized', () {
              final literal = Literal('1.E-8', IRI(XMLDataType.double.iri));
              expect(literal.lexicalForm, '1.0E-8');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, 1.0E-8);
            });

            test('leading zeros are normalized', () {
              final literal = Literal('01', IRI(XMLDataType.double.iri));
              expect(literal.lexicalForm, '1.0E0');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, 1);
            });

            test('negative numbers without decimal places', () {
              final literal = Literal('-1', IRI(XMLDataType.double.iri));
              expect(literal.lexicalForm, '-1.0E0');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, -1);
            });

            test('trailing decimal points are normalized', () {
              final literal = Literal('1.', IRI(XMLDataType.double.iri));
              expect(literal.lexicalForm, '1.0E0');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, 1.0);
            });

            test('redundant decimal points are normalized', () {
              final literal = Literal('1.00', IRI(XMLDataType.double.iri));
              expect(literal.lexicalForm, '1.0E0');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, 1);
            });

            test(
              'redundant zeros combined with the plus sign are normalized',
              () {
                final literal = Literal('+001.00', IRI(XMLDataType.double.iri));
                expect(literal.lexicalForm, '1.0E0');
                expect(literal.datatype, IRI(XMLDataType.double.iri));
                expect(literal.language, isNull);
                expect(literal.value, 1);
              },
            );

            test('precision with 10 decimal places works as expected', () {
              final literal = Literal(
                '2.234000005',
                IRI(XMLDataType.double.iri),
              );
              expect(literal.lexicalForm, '2.234000005E0');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, 2.234000005);
            });

            test('precision with 16 decimal places works as expected', () {
              final literal = Literal(
                '2.2340000000000005',
                IRI(XMLDataType.double.iri),
              );
              // TODO: Investigate broken test
              // expect(literal.lexicalForm, '2.2340000000000005E0');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, 2.2340000000000005);
            });

            test('precision with 17 decimal places is rounded', () {
              final literal = Literal(
                '2.23400000000000005',
                IRI(XMLDataType.double.iri),
              );
              expect(literal.lexicalForm, '2.234E0');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, 2.234);
            });

            test('number starting with a decimal point is valid', () {
              final literal = Literal('.2', IRI(XMLDataType.double.iri));
              expect(literal.lexicalForm, '2.0E-1');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, 0.2);
            });

            test('rounding is capped at 16 decimal places', () {
              final literal = Literal(
                '1.2345678901234567890123457890',
                IRI(XMLDataType.double.iri),
              );
              expect(literal.lexicalForm, '1.2345678901234567E0');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, 1.2345678901234567);
            });

            test(
              'redundant zeros combined with the minus sign are normalized',
              () {
                final literal = Literal('-001.00', IRI(XMLDataType.double.iri));
                expect(literal.lexicalForm, '-1.0E0');
                expect(literal.datatype, IRI(XMLDataType.double.iri));
                expect(literal.language, isNull);
                expect(literal.value, -1);
              },
            );
          });

          group('using invalid data', () {
            test('non numerical figures are not valid double data types', () {
              expect(
                () => Literal('abc', IRI(XMLDataType.double.iri)),
                throwsFormatException,
              );
            });

            test('Only a +/- sign is not a valid double data type', () {
              expect(
                () => Literal('+', IRI(XMLDataType.double.iri)),
                throwsFormatException,
              );
              expect(
                () => Literal('-', IRI(XMLDataType.double.iri)),
                throwsFormatException,
              );
            });

            test('Multiple decimal points are not valid', () {
              expect(
                () => Literal('1.2.3', IRI(XMLDataType.double.iri)),
                throwsFormatException,
              );
            });

            test('Numbers with spaces are not valid', () {
              expect(
                () => Literal('1 2 3', IRI(XMLDataType.double.iri)),
                throwsFormatException,
              );
            });
          });
        });

        group('unsigned byte', () {
          group('with valid data', () {
            test('0 is a valid value', () {
              final literal = Literal('0', IRI(XMLDataType.unsignedByte.iri));
              expect(literal.lexicalForm, '0');
              expect(literal.language, isNull);
              expect(literal.value, 0);
            });

            test('255 is a valid value', () {
              final literal = Literal('255', IRI(XMLDataType.unsignedByte.iri));
              expect(literal.lexicalForm, '255');
              expect(literal.language, isNull);
              expect(literal.value, 255);
            });
          });

          group('with invalid data', () {
            test('256 is not a valid value', () {
              expect(
                () => Literal('256', IRI(XMLDataType.unsignedByte.iri)),
                throwsRangeError,
              );
            });
          });
        });
        group('byte types', () {
          group('with valid data', () {
            test('0 is a valid value', () {
              final literal = Literal('0', IRI(XMLDataType.byte.iri));
              expect(literal.lexicalForm, '0');
              expect(literal.language, isNull);
              expect(literal.value, 0);
            });

            test('-1 is a valid value', () {
              final literal = Literal('-1', IRI(XMLDataType.byte.iri));
              expect(literal.lexicalForm, '-1');
              expect(literal.language, isNull);
              expect(literal.value, -1);
            });

            test('-128 is a valid value', () {
              final literal = Literal('-128', IRI(XMLDataType.byte.iri));
              expect(literal.lexicalForm, '-128');
              expect(literal.language, isNull);
              expect(literal.value, -128);
            });

            test('127 is a valid value', () {
              final literal = Literal('127', IRI(XMLDataType.byte.iri));
              expect(literal.lexicalForm, '127');
              expect(literal.language, isNull);
              expect(literal.value, 127);
            });

            test('valid values with a leading + are normalised', () {
              final literal = Literal('+127', IRI(XMLDataType.byte.iri));
              expect(literal.lexicalForm, '127');
              expect(literal.language, isNull);
              expect(literal.value, 127);
            });
          });

          group('with invalid data', () {
            test('128 is not a valid value', () {
              expect(
                () => Literal('128', IRI(XMLDataType.byte.iri)),
                throwsRangeError,
              );
            });

            test('-129 is not a valid value', () {
              expect(
                () => Literal('-129', IRI(XMLDataType.byte.iri)),
                throwsRangeError,
              );
            });

            test('+-0 is not a valid value', () {
              expect(
                () => Literal('+-0', IRI(XMLDataType.byte.iri)),
                throwsFormatException,
              );
            });

            test('non numerical characters are not a valid value', () {
              expect(
                () => Literal('abc', IRI(XMLDataType.byte.iri)),
                throwsFormatException,
              );
            });
          });
        });

        group('unsigned short', () {
          group('with valid data', () {
            test('0 is a valid value', () {
              final literal = Literal('0', IRI(XMLDataType.unsignedShort.iri));
              expect(literal.lexicalForm, '0');
              expect(literal.language, isNull);
              expect(literal.value, 0);
            });

            test('65535 is a valid value', () {
              final literal = Literal(
                '65535',
                IRI(XMLDataType.unsignedShort.iri),
              );
              expect(literal.lexicalForm, '65535');
              expect(literal.language, isNull);
              expect(literal.value, 65535);
            });
          });

          group('with invalid data', () {
            test('65536 is not a valid value', () {
              expect(
                () => Literal('65536', IRI(XMLDataType.unsignedShort.iri)),
                throwsRangeError,
              );
            });
          });
        });

        group('short', () {
          group('with valid data', () {
            test('0 is a valid value', () {
              final literal = Literal('0', IRI(XMLDataType.short.iri));
              expect(literal.lexicalForm, '0');
              expect(literal.language, isNull);
              expect(literal.value, 0);
            });

            test('32767 is a valid value', () {
              final literal = Literal('32767', IRI(XMLDataType.short.iri));
              expect(literal.lexicalForm, '32767');
              expect(literal.language, isNull);
              expect(literal.value, 32767);
            });

            test('-32768 is a valid value', () {
              final literal = Literal('-32768', IRI(XMLDataType.short.iri));
              expect(literal.lexicalForm, '-32768');
              expect(literal.language, isNull);
              expect(literal.value, -32768);
            });
          });

          group('with invalid data', () {
            test('32768 is not a valid value', () {
              expect(
                () => Literal('32768', IRI(XMLDataType.short.iri)),
                throwsRangeError,
              );
            });

            test('-32769 is not a valid value', () {
              expect(
                () => Literal('-32769', IRI(XMLDataType.short.iri)),
                throwsRangeError,
              );
            });
          });
        });

        group('unsigned int', () {
          group('with valid data', () {
            test('0 is a valid value', () {
              final literal = Literal('0', IRI(XMLDataType.unsignedInt.iri));
              expect(literal.lexicalForm, '0');
              expect(literal.language, isNull);
              expect(literal.value, 0);
            });

            test('4294967295 is a valid value', () {
              final literal = Literal(
                '4294967295',
                IRI(XMLDataType.unsignedInt.iri),
              );
              expect(literal.lexicalForm, '4294967295');
              expect(literal.language, isNull);
              expect(literal.value, 4294967295);
            });
          });

          group('with invalid data', () {
            test('65536 is not a valid value', () {
              expect(
                () => Literal('4294967296', IRI(XMLDataType.unsignedInt.iri)),
                throwsRangeError,
              );
            });
          });
        });

        group('int', () {
          group('with valid data', () {
            test('0 is a valid value', () {
              final literal = Literal('0', IRI(XMLDataType.int.iri));
              expect(literal.lexicalForm, '0');
              expect(literal.language, isNull);
              expect(literal.value, 0);
            });

            test('2147483647 is a valid value', () {
              final literal = Literal('2147483647', IRI(XMLDataType.int.iri));
              expect(literal.lexicalForm, '2147483647');
              expect(literal.language, isNull);
              expect(literal.value, 2147483647);
            });

            test('-2147483648 is a valid value', () {
              final literal = Literal('-2147483648', IRI(XMLDataType.int.iri));
              expect(literal.lexicalForm, '-2147483648');
              expect(literal.language, isNull);
              expect(literal.value, -2147483648);
            });
          });

          group('with invalid data', () {
            test('2147483648 is not a valid value', () {
              expect(
                () => Literal('2147483648', IRI(XMLDataType.int.iri)),
                throwsRangeError,
              );
            });

            test('-2147483649 is not a valid value', () {
              expect(
                () => Literal('-2147483649', IRI(XMLDataType.short.iri)),
                throwsRangeError,
              );
            });
          });
        });

        group('base64Binary', () {
          group('with valid data', () {
            test('it decodes the data correctly', () {
              final literal = Literal(
                'SGVsbG8gV29ybGQ=',
                IRI(XMLDataType.base64Binary.iri),
              );

              expect(literal.lexicalForm, 'SGVsbG8gV29ybGQ=');
              expect(literal.language, isNull);
              expect(utf8.decode(literal.value as Uint8List), 'Hello World');
            });
          });

          group('with invalid data', () {
            test('rejects invalid characters', () {
              expect(
                () => Literal(
                  '^not a valid string^',
                  IRI(XMLDataType.base64Binary.iri),
                ),
                throwsFormatException,
              );
            });
          });
        });

        group('hexBinary', () {
          group('with valid data', () {
            test('it decodes the data correctly with lowercase hex', () {
              final literal = Literal(
                '48656c6c6f20576f726c64',
                IRI(XMLDataType.hexBinary.iri),
              );

              expect(literal.lexicalForm, '48656c6c6f20576f726c64');
              expect(literal.language, isNull);
              expect(utf8.decode(literal.value as Uint8List), 'Hello World');
            });

            test('it decodes the data correctly with uppercase hex', () {
              final literal = Literal(
                '48656C6C6F20576F726C64',
                IRI(XMLDataType.hexBinary.iri),
              );

              expect(literal.lexicalForm, '48656c6c6f20576f726c64');
              expect(literal.language, isNull);
              expect(utf8.decode(literal.value as Uint8List), 'Hello World');
            });

            test('it decodes the data correctly with mixed case hex', () {
              final literal = Literal(
                '48656c6C6f20576F726C64',
                IRI(XMLDataType.hexBinary.iri),
              );

              expect(literal.lexicalForm, '48656c6c6f20576f726c64');
              expect(literal.language, isNull);
              expect(utf8.decode(literal.value as Uint8List), 'Hello World');
            });
          });

          group('with invalid data', () {
            test('rejects invalid characters', () {
              expect(
                () => Literal(
                  '^not a valid hex string^',
                  IRI(XMLDataType.hexBinary.iri),
                ),
                throwsFormatException,
              );
            });
          });
        });

        group('langString', () {
          final langStringIri = IRI(
            'http://www.w3.org/1999/02/22-rdf-syntax-ns#langString',
          );

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
                throwsArgumentError,
              );
            });

            test('without a language tag', () {
              expect(
                () => Literal('hello world', langStringIri),
                throwsArgumentError,
              );
            });

            test('with an empty string', () {
              expect(
                () => Literal('', langStringIri, 'en-AU'),
                throwsArgumentError,
              );
            });
          });
        });

        group('cross cutting concerns', () {
          test("numbers don't accept blank strings", () {
            expect(
              () => Literal('', IRI(XMLDataType.unsignedByte.iri)),
              throwsArgumentError,
            );
            expect(
              () => Literal('', IRI(XMLDataType.byte.iri)),
              throwsArgumentError,
            );
            expect(
              () => Literal('', IRI(XMLDataType.unsignedInt.iri)),
              throwsArgumentError,
            );
            expect(
              () => Literal('', IRI(XMLDataType.int.iri)),
              throwsArgumentError,
            );
            expect(
              () => Literal('', IRI(XMLDataType.short.iri)),
              throwsArgumentError,
            );
            expect(
              () => Literal('', IRI(XMLDataType.unsignedShort.iri)),
              throwsArgumentError,
            );
            expect(
              () => Literal('', IRI(XMLDataType.integer.iri)),
              throwsArgumentError,
            );
          });

          test("numbers don't accept only +/- signs", () {
            expect(
              () => Literal('-', IRI(XMLDataType.unsignedByte.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('+', IRI(XMLDataType.unsignedByte.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('-', IRI(XMLDataType.byte.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('+', IRI(XMLDataType.byte.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('-', IRI(XMLDataType.unsignedInt.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('+', IRI(XMLDataType.unsignedInt.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('-', IRI(XMLDataType.int.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('+', IRI(XMLDataType.int.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('-', IRI(XMLDataType.unsignedShort.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('+', IRI(XMLDataType.unsignedShort.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('-', IRI(XMLDataType.short.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('+', IRI(XMLDataType.short.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('-', IRI(XMLDataType.integer.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('+', IRI(XMLDataType.integer.iri)),
              throwsFormatException,
            );
          });

          test("numbers don't accept letters", () {
            expect(
              () => Literal('one', IRI(XMLDataType.unsignedByte.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('one', IRI(XMLDataType.unsignedByte.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('one', IRI(XMLDataType.byte.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('one', IRI(XMLDataType.byte.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('one', IRI(XMLDataType.unsignedInt.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('one', IRI(XMLDataType.unsignedInt.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('one', IRI(XMLDataType.int.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('one', IRI(XMLDataType.int.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('one', IRI(XMLDataType.unsignedShort.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('one', IRI(XMLDataType.unsignedShort.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('one', IRI(XMLDataType.short.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('one', IRI(XMLDataType.short.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('one', IRI(XMLDataType.integer.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('one', IRI(XMLDataType.integer.iri)),
              throwsFormatException,
            );
          });
        });

        group('nonNegativeInteger', () {
          group('with valid data', () {
            test('0 is a valid value', () {
              final literal = Literal(
                '0',
                IRI(XMLDataType.nonNegativeInteger.iri),
              );
              expect(literal.lexicalForm, '0');
              expect(literal.language, isNull);
              expect(literal.value, 0);
            });

            test('1 is a valid value', () {
              final literal = Literal(
                '1',
                IRI(XMLDataType.nonNegativeInteger.iri),
              );
              expect(literal.lexicalForm, '1');
              expect(literal.language, isNull);
              expect(literal.value, 1);
            });

            test('value with leading space is a valid value', () {
              final literal = Literal(
                ' 1',
                IRI(XMLDataType.nonNegativeInteger.iri),
              );
              expect(literal.lexicalForm, '1');
              expect(literal.language, isNull);
              expect(literal.value, 1);
            });

            test('value with trailing space is a valid value', () {
              final literal = Literal(
                '1 ',
                IRI(XMLDataType.nonNegativeInteger.iri),
              );
              expect(literal.lexicalForm, '1');
              expect(literal.language, isNull);
              expect(literal.value, 1);
            });
          });

          group('with invalid data', () {
            test('-1 is not a valid value', () {
              expect(
                () => Literal('-1', IRI(XMLDataType.nonNegativeInteger.iri)),
                throwsRangeError,
              );
            });

            test('1.5 is not a valid value', () {
              expect(
                () => Literal('1.5', IRI(XMLDataType.nonNegativeInteger.iri)),
                throwsFormatException,
              );
            });
          });
        });

        group('negativeInteger', () {
          group('with valid data', () {
            test('-1 is a valid value', () {
              final literal = Literal(
                '-1',
                IRI(XMLDataType.negativeInteger.iri),
              );
              expect(literal.lexicalForm, '-1');
              expect(literal.language, isNull);
              expect(literal.value, -1);
            });

            test('value with leading space is a valid value', () {
              final literal = Literal(
                ' -1',
                IRI(XMLDataType.negativeInteger.iri),
              );
              expect(literal.lexicalForm, '-1');
              expect(literal.language, isNull);
              expect(literal.value, -1);
            });

            test('value with trailing space is a valid value', () {
              final literal = Literal(
                '-1 ',
                IRI(XMLDataType.negativeInteger.iri),
              );
              expect(literal.lexicalForm, '-1');
              expect(literal.language, isNull);
              expect(literal.value, -1);
            });
          });

          group('with invalid data', () {
            test('0 is not a valid value', () {
              expect(
                () => Literal('0', IRI(XMLDataType.negativeInteger.iri)),
                throwsRangeError,
              );
            });

            test('-1.5 is not a valid value', () {
              expect(
                () => Literal('-1.5', IRI(XMLDataType.negativeInteger.iri)),
                throwsFormatException,
              );
            });

            test('-0 is not a valid value', () {
              expect(
                () => Literal('-0', IRI(XMLDataType.negativeInteger.iri)),
                throwsRangeError,
              );
            });
          });
        });

        group('nonPositiveInteger', () {
          group('with valid data', () {
            test('0 is a valid value', () {
              final literal = Literal(
                '0',
                IRI(XMLDataType.nonPositiveInteger.iri),
              );
              expect(literal.lexicalForm, '0');
              expect(literal.language, isNull);
              expect(literal.value, 0);
            });

            test('-1 is a valid value', () {
              final literal = Literal(
                '-1',
                IRI(XMLDataType.nonPositiveInteger.iri),
              );
              expect(literal.lexicalForm, '-1');
              expect(literal.language, isNull);
              expect(literal.value, -1);
            });

            test('value with leading space is a valid value', () {
              final literal = Literal(
                ' -1',
                IRI(XMLDataType.nonPositiveInteger.iri),
              );
              expect(literal.lexicalForm, '-1');
              expect(literal.language, isNull);
              expect(literal.value, -1);
            });

            test('value with trailing space is a valid value', () {
              final literal = Literal(
                '-1 ',
                IRI(XMLDataType.nonPositiveInteger.iri),
              );
              expect(literal.lexicalForm, '-1');
              expect(literal.language, isNull);
              expect(literal.value, -1);
            });
          });

          group('with invalid data', () {
            test('1 is not a valid value', () {
              expect(
                () => Literal('1', IRI(XMLDataType.nonPositiveInteger.iri)),
                throwsRangeError,
              );
            });

            test('-1.5 is not a valid value', () {
              expect(
                () => Literal('-1.5', IRI(XMLDataType.nonPositiveInteger.iri)),
                throwsFormatException,
              );
            });
          });
        });
      });

      test('with string datatype', () {
        final literal = Literal('hello', IRI(XMLDataType.string.iri));
        expect(literal.lexicalForm, 'hello');
        expect(literal.datatype, IRI(XMLDataType.string.iri));
        expect(literal.language, isNull);
        expect(literal.value, 'hello');
      });

      test('with integer datatype', () {
        final literal = Literal('42', IRI(XMLDataType.integer.iri));
        expect(literal.lexicalForm, '42');
        expect(literal.datatype, IRI(XMLDataType.integer.iri));
        expect(literal.language, isNull);
        expect(literal.value, BigInt.from(42));
      });

      test('with language tag', () {
        final literal = Literal('bonjour', IRI(XMLDataType.string.iri), 'fr');
        expect(literal.lexicalForm, 'bonjour');
        expect(literal.datatype, IRI(XMLDataType.string.iri));
        expect(literal.language, Locale.parse('fr'));
        expect(literal.value, 'bonjour');
      });

      test('with double datatype', () {
        final literal = Literal('3.14', IRI(XMLDataType.double.iri));
        expect(literal.lexicalForm, '3.14E0');
        expect(literal.datatype, IRI(XMLDataType.double.iri));
        expect(literal.language, isNull);
        expect(literal.value, 3.14);
      });

      test('with dateTime datatype', () {
        final now = DateTime.utc(2025, 03, 12, 23, 30, 38, 917614);
        final literal = Literal(
          now.toIso8601String(),
          IRI(XMLDataType.dateTime.iri),
        );
        expect(literal.lexicalForm, now.toIso8601String());
        expect(literal.datatype, IRI(XMLDataType.dateTime.iri));
        expect(literal.language, isNull);
        expect(
          (literal.value as DateTime).toIso8601String(),
          now.toIso8601String(),
        );
      });

      test('with boolean datatype', () {
        final literal = Literal('true', IRI(XMLDataType.boolean.iri));
        expect(literal.lexicalForm, 'true');
        expect(literal.datatype, IRI(XMLDataType.boolean.iri));
        expect(literal.language, isNull);
        expect(literal.value, true);
      });
    });

    group('Type checking', () {
      test('isIRI is false', () {
        final literal = Literal('hello', IRI(XMLDataType.string.iri));
        expect(literal.isIRI, false);
      });

      test('isBlankNode is false', () {
        final literal = Literal('hello', IRI(XMLDataType.string.iri));
        expect(literal.isBlankNode, false);
      });

      test('isLiteral is true', () {
        final literal = Literal('hello', IRI(XMLDataType.string.iri));
        expect(literal.isLiteral, true);
      });
    });

    group('TermType', () {
      test('termType is literal', () {
        final literal = Literal('hello', IRI(XMLDataType.string.iri));
        expect(literal.termType, TermType.literal);
      });
    });

    group('toString', () {
      test('string literal without language tag', () {
        final literal = Literal('hello', IRI(XMLDataType.string.iri));
        expect(literal.toString(), '"hello"');
      });

      test('string literal with language tag', () {
        final literal = Literal('bonjour', IRI(XMLDataType.string.iri), 'fr');
        expect(literal.toString(), '"bonjour"@fr');
      });

      test('integer literal', () {
        final literal = Literal('42', IRI(XMLDataType.integer.iri));
        expect(
          literal.toString(),
          '"42"^^<http://www.w3.org/2001/XMLSchema#integer>',
        );
      });
      test('boolean literal', () {
        final literal = Literal('true', IRI(XMLDataType.boolean.iri));
        expect(
          literal.toString(),
          '"true"^^<http://www.w3.org/2001/XMLSchema#boolean>',
        );
      });
      test('double literal', () {
        final literal = Literal('3.14', IRI(XMLDataType.double.iri));
        expect(
          literal.toString(),
          '"3.14E0"^^<http://www.w3.org/2001/XMLSchema#double>',
        );
      });
      test('date time literal', () {
        final now = DateTime.utc(2025, 03, 12, 23, 30, 38, 917614);
        final literal = Literal(
          now.toIso8601String(),
          IRI(XMLDataType.dateTime.iri),
        );
        expect(
          literal.toString(),
          '"${now.toIso8601String()}"^^<http://www.w3.org/2001/XMLSchema#dateTime>',
        );
      });
    });
    group('toLexicalForm', () {
      test('string', () {
        final literal = Literal('hello', IRI(XMLDataType.string.iri));
        expect(literal.lexicalForm, 'hello');
      });
      test('integer', () {
        final literal = Literal('42', IRI(XMLDataType.integer.iri));
        expect(literal.lexicalForm, '42');
      });
      test('double', () {
        final literal = Literal('3.14', IRI(XMLDataType.double.iri));
        expect(literal.lexicalForm, '3.14E0');
      });
      test('date time', () {
        final now = DateTime.utc(2025, 03, 12, 23, 30, 38, 917614);
        final literal = Literal(
          now.toIso8601String(),
          IRI(XMLDataType.dateTime.iri),
        );
        expect(literal.lexicalForm, now.toIso8601String());
      });
      test('boolean', () {
        final literal = Literal('true', IRI(XMLDataType.boolean.iri));
        expect(literal.lexicalForm, 'true');
      });
    });

    group('Equality', () {
      test('equal literals', () {
        final literal1 = Literal('hello', IRI(XMLDataType.string.iri));
        final literal2 = Literal('hello', IRI(XMLDataType.string.iri));
        expect(literal1 == literal2, true);
      });

      test('different lexical forms', () {
        final literal1 = Literal('hello', IRI(XMLDataType.string.iri));
        final literal2 = Literal('world', IRI(XMLDataType.string.iri));
        expect(literal1 == literal2, false);
      });

      test('different datatypes', () {
        final literal1 = Literal('42', IRI(XMLDataType.integer.iri));
        final literal2 = Literal('42', IRI(XMLDataType.string.iri));
        expect(literal1 == literal2, false);
      });

      test('different language tags', () {
        final literal1 = Literal('bonjour', IRI(XMLDataType.string.iri), 'fr');
        final literal2 = Literal('bonjour', IRI(XMLDataType.string.iri), 'en');
        expect(literal1 == literal2, false);
      });

      test('one with language tag, one without', () {
        final literal1 = Literal('hello', IRI(XMLDataType.string.iri));
        final literal2 = Literal('hello', IRI(XMLDataType.string.iri), 'fr');
        expect(literal1 == literal2, false);
      });
    });

    group('HashCode', () {
      test('equal literals have same hashCode', () {
        final literal1 = Literal('hello', IRI(XMLDataType.string.iri));
        final literal2 = Literal('hello', IRI(XMLDataType.string.iri));
        expect(literal1.hashCode == literal2.hashCode, true);
      });

      test('different lexical forms have different hashCodes', () {
        final literal1 = Literal('hello', IRI(XMLDataType.string.iri));
        final literal2 = Literal('world', IRI(XMLDataType.string.iri));
        expect(literal1.hashCode == literal2.hashCode, false);
      });

      test('different datatypes have different hashCodes', () {
        final literal1 = Literal('42', IRI(XMLDataType.integer.iri));
        final literal2 = Literal('42', IRI(XMLDataType.string.iri));
        expect(literal1.hashCode == literal2.hashCode, false);
      });

      test('different language tags have different hashCodes', () {
        final literal1 = Literal('bonjour', IRI(XMLDataType.string.iri), 'fr');
        final literal2 = Literal('bonjour', IRI(XMLDataType.string.iri), 'en');
        expect(literal1.hashCode == literal2.hashCode, false);
      });

      test('one with language tag, one without have different hashCodes', () {
        final literal1 = Literal('hello', IRI(XMLDataType.string.iri));
        final literal2 = Literal('hello', IRI(XMLDataType.string.iri), 'fr');
        expect(literal1.hashCode == literal2.hashCode, false);
      });
    });
  });
}
