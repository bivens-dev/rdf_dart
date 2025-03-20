import 'package:rdf_dart/rdf_dart.dart';
import 'package:rdf_dart/src/data_type_facets.dart';
import 'package:test/test.dart';

void main() {
  group('Literal', () {
    group('Creation', () {
      group('XML Schema Datatypes', () {
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
              expect(literal.toLexicalForm(), 'false');
            });

            test('true is serialized as correctly', () {
              final literal = Literal('1', IRI(XMLDataType.boolean.iri));
              expect(literal.toLexicalForm(), 'true');
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

            test(
              'valid values with a trailing space are not a valid boolean data type',
              () {
                expect(
                  () => Literal('false ', IRI(XMLDataType.boolean.iri)),
                  throwsFormatException,
                );
                expect(
                  () => Literal('true ', IRI(XMLDataType.boolean.iri)),
                  throwsFormatException,
                );
              },
            );

            test(
              'valid values with a leading space are not a valid boolean data type',
              () {
                expect(
                  () => Literal(' false', IRI(XMLDataType.boolean.iri)),
                  throwsFormatException,
                );
                expect(
                  () => Literal(' true', IRI(XMLDataType.boolean.iri)),
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

        group('double', () {
          group('using valid data', () {
            test('with decimal places', () {
              final literal = Literal('3.14', IRI(XMLDataType.double.iri));
              expect(literal.toLexicalForm(), '3.14E0');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, 3.14);
            });

            test('values without decimal places are normalized', () {
              final literal = Literal('1', IRI(XMLDataType.double.iri));
              expect(literal.toLexicalForm(), '1.0E0');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, 1.0);
            });

            test('values with lowercase e exponents are normalized', () {
              final literal = Literal('1.0e+1', IRI(XMLDataType.double.iri));
              expect(literal.toLexicalForm(), '1.0E1');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, 1.0E1);
            });

            test('INF is a valid value', () {
              final literal = Literal('INF', IRI(XMLDataType.double.iri));
              expect(literal.toLexicalForm(), 'INF');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, double.infinity);
            });

            test('-INF is a valid value', () {
              final literal = Literal('-INF', IRI(XMLDataType.double.iri));
              expect(literal.toLexicalForm(), '-INF');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, double.negativeInfinity);
            });

            test('+INF is a valid value', () {
              final literal = Literal('+INF', IRI(XMLDataType.double.iri));
              expect(literal.toLexicalForm(), 'INF');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, double.infinity);
            });

            test('inf is a valid value', () {
              final literal = Literal('inf', IRI(XMLDataType.double.iri));
              expect(literal.toLexicalForm(), 'INF');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, double.infinity);
            });

            test('values with exponents are normalized', () {
              final literal = Literal('1.E-8', IRI(XMLDataType.double.iri));
              expect(literal.toLexicalForm(), '1.0E-8');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, 1.0E-8);
            });

            test('leading zeros are normalized', () {
              final literal = Literal('01', IRI(XMLDataType.double.iri));
              expect(literal.toLexicalForm(), '1.0E0');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, 1);
            });

            test('negative numbers without decimal places', () {
              final literal = Literal('-1', IRI(XMLDataType.double.iri));
              expect(literal.toLexicalForm(), '-1.0E0');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, -1);
            });

            test('trailing decimal points are normalized', () {
              final literal = Literal('1.', IRI(XMLDataType.double.iri));
              expect(literal.toLexicalForm(), '1.0E0');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, 1.0);
            });

            test('redundant decimal points are normalized', () {
              final literal = Literal('1.00', IRI(XMLDataType.double.iri));
              expect(literal.toLexicalForm(), '1.0E0');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, 1);
            });

            test(
              'redundant zeros combined with the plus sign are normalized',
              () {
                final literal = Literal('+001.00', IRI(XMLDataType.double.iri));
                expect(literal.toLexicalForm(), '1.0E0');
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
              expect(literal.toLexicalForm(), '2.234000005E0');
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
              // expect(literal.toLexicalForm(), '2.2340000000000005E0');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, 2.2340000000000005);
            });

            test('precision with 17 decimal places is rounded', () {
              final literal = Literal(
                '2.23400000000000005',
                IRI(XMLDataType.double.iri),
              );
              expect(literal.toLexicalForm(), '2.234E0');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, 2.234);
            });

            test('number starting with a decimal point is valid', () {
              final literal = Literal('.2', IRI(XMLDataType.double.iri));
              expect(literal.toLexicalForm(), '2.0E-1');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, 0.2);
            });

            test('rounding is capped at 16 decimal places', () {
              final literal = Literal(
                '1.2345678901234567890123457890',
                IRI(XMLDataType.double.iri),
              );
              expect(literal.toLexicalForm(), '1.2345678901234567E0');
              expect(literal.datatype, IRI(XMLDataType.double.iri));
              expect(literal.language, isNull);
              expect(literal.value, 1.2345678901234567);
            });

            test(
              'redundant zeros combined with the minus sign are normalized',
              () {
                final literal = Literal('-001.00', IRI(XMLDataType.double.iri));
                expect(literal.toLexicalForm(), '-1.0E0');
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
              expect(
                () => Literal(' 123', IRI(XMLDataType.double.iri)),
                throwsFormatException,
              );
              expect(
                () => Literal('123 ', IRI(XMLDataType.double.iri)),
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
              expect(literal.toLexicalForm(), '0');
              expect(literal.language, isNull);
              expect(literal.value, 0);
            });

            test('-1 is a valid value', () {
              final literal = Literal('-1', IRI(XMLDataType.byte.iri));
              expect(literal.toLexicalForm(), '-1');
              expect(literal.language, isNull);
              expect(literal.value, -1);
            });

            test('-128 is a valid value', () {
              final literal = Literal('-128', IRI(XMLDataType.byte.iri));
              expect(literal.toLexicalForm(), '-128');
              expect(literal.language, isNull);
              expect(literal.value, -128);
            });

            test('127 is a valid value', () {
              final literal = Literal('127', IRI(XMLDataType.byte.iri));
              expect(literal.toLexicalForm(), '127');
              expect(literal.language, isNull);
              expect(literal.value, 127);
            });

            test('valid values with a leading + are normalised', () {
              final literal = Literal('+127', IRI(XMLDataType.byte.iri));
              expect(literal.toLexicalForm(), '127');
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
              expect(literal.toLexicalForm(), '0');
              expect(literal.language, isNull);
              expect(literal.value, 0);
            });

            test('65535 is a valid value', () {
              final literal = Literal(
                '65535',
                IRI(XMLDataType.unsignedShort.iri),
              );
              expect(literal.toLexicalForm(), '65535');
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
              expect(literal.toLexicalForm(), '0');
              expect(literal.language, isNull);
              expect(literal.value, 0);
            });

            test('32767 is a valid value', () {
              final literal = Literal('32767', IRI(XMLDataType.short.iri));
              expect(literal.toLexicalForm(), '32767');
              expect(literal.language, isNull);
              expect(literal.value, 32767);
            });

            test('-32768 is a valid value', () {
              final literal = Literal('-32768', IRI(XMLDataType.short.iri));
              expect(literal.toLexicalForm(), '-32768');
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
              expect(literal.toLexicalForm(), '0');
              expect(literal.language, isNull);
              expect(literal.value, 0);
            });

            test('4294967295 is a valid value', () {
              final literal = Literal(
                '4294967295',
                IRI(XMLDataType.unsignedInt.iri),
              );
              expect(literal.toLexicalForm(), '4294967295');
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
              expect(literal.toLexicalForm(), '0');
              expect(literal.language, isNull);
              expect(literal.value, 0);
            });

            test('2147483647 is a valid value', () {
              final literal = Literal('2147483647', IRI(XMLDataType.int.iri));
              expect(literal.toLexicalForm(), '2147483647');
              expect(literal.language, isNull);
              expect(literal.value, 2147483647);
            });

            test('-2147483648 is a valid value', () {
              final literal = Literal('-2147483648', IRI(XMLDataType.int.iri));
              expect(literal.toLexicalForm(), '-2147483648');
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

        group('cross cutting concerns', () {
          test("unsigned numeric types don't accept +/- signs", () {
            expect(
              () => Literal('-0', IRI(XMLDataType.unsignedByte.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('+0', IRI(XMLDataType.unsignedByte.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('-0', IRI(XMLDataType.unsignedInt.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('+0', IRI(XMLDataType.unsignedInt.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('-0', IRI(XMLDataType.unsignedShort.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('+0', IRI(XMLDataType.unsignedShort.iri)),
              throwsFormatException,
            );
          });

          test("numbers don't accept blank strings", () {
            expect(
              () => Literal('', IRI(XMLDataType.unsignedByte.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('', IRI(XMLDataType.byte.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('', IRI(XMLDataType.unsignedInt.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('', IRI(XMLDataType.int.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('', IRI(XMLDataType.short.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('', IRI(XMLDataType.unsignedShort.iri)),
              throwsFormatException,
            );
            expect(
              () => Literal('', IRI(XMLDataType.integer.iri)),
              throwsFormatException,
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
        expect(literal.language, 'fr');
        expect(literal.value, 'bonjour');
      });
      test('with double datatype', () {
        final literal = Literal('3.14', IRI(XMLDataType.double.iri));
        expect(literal.lexicalForm, '3.14');
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
        expect(literal.toLexicalForm(), 'hello');
      });
      test('integer', () {
        final literal = Literal('42', IRI(XMLDataType.integer.iri));
        expect(literal.toLexicalForm(), '42');
      });
      test('double', () {
        final literal = Literal('3.14', IRI(XMLDataType.double.iri));
        expect(literal.toLexicalForm(), '3.14E0');
      });
      test('date time', () {
        final now = DateTime.utc(2025, 03, 12, 23, 30, 38, 917614);
        final literal = Literal(
          now.toIso8601String(),
          IRI(XMLDataType.dateTime.iri),
        );
        expect(literal.toLexicalForm(), now.toIso8601String());
      });
      test('boolean', () {
        final literal = Literal('true', IRI(XMLDataType.boolean.iri));
        expect(literal.toLexicalForm(), 'true');
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
