import 'package:rdf_dart/src/punycode/encoder.dart';
import 'package:rdf_dart/src/punycode/punycode_codec.dart';
import 'package:test/test.dart';

void main() {
  group('PunycodeEncoder', () {
    late PunycodeCodec codec;

    setUp(() {
      codec = PunycodeCodec();
    });

    test('multiple non-ASCII characters', () {
      expect(codec.encoder.convert('üëäö♥'), '4can8av2009b');
    });

    test('a single non-ASCII character', () {
      expect(codec.encoder.convert('ü'), 'tda');
    });

    test('a single basic code point', () {
      expect(codec.encoder.convert('Bach'), 'Bach-');
    });

    test('mix of ASCII and non-ASCII characters', () {
      expect(codec.encoder.convert('bücher'), 'bcher-kva');
    });

    test('long string with both ASCII and non-ASCII characters', () {
      expect(
        codec.encoder.convert(
          'Willst du die Blüthe des frühen, die Früchte des späteren Jahres',
        ),
        'Willst du die Blthe des frhen, die Frchte des spteren Jahres-x9e96lkal',
      );
    });

    // https://datatracker.ietf.org/doc/html/rfc3492#section-7.1
    group('Official RFC examples', () {
      test('Arabic (Egyptian)', () {
        expect(
          codec.encoder.convert('ليهمابتكلموشعربي؟'),
          'egbpdaj6bu4bxfgehfvwxn',
        );
      });

      test('Chinese (simplified)', () {
        expect(codec.encoder.convert('他们为什么不说中文'), 'ihqwcrb4cv8a8dqg056pqjye');
      });

      test('Chinese (traditional)', () {
        expect(
          codec.encoder.convert('他們爲什麽不說中文'),
          'ihqwctvzc91f659drss3x8bo0yb',
        );
      });

      test('Czech', () {
        expect(
          codec.encoder.convert('Pročprostěnemluvíčesky'),
          'Proprostnemluvesky-uyb24dma41a',
        );
      });

      test('Hebrew', () {
        expect(
          codec.encoder.convert('למההםפשוטלאמדבריםעברית'),
          '4dbcagdahymbxekheh6e0a7fei0b',
        );
      });

      test('Hindi (Devanagari)', () {
        expect(
          codec.encoder.convert('यहलोगहिन्दीक्योंनहींबोलसकतेहैं'),
          'i1baa7eci9glrd9b2ae1bj0hfcgg6iyaf8o0a1dig0cd',
        );
      });

      test('Japanese (kanji and hiragana)', () {
        expect(
          codec.encoder.convert('なぜみんな日本語を話してくれないのか'),
          'n8jok5ay5dzabd5bym9f0cm5685rrjetr6pdxa',
        );
      });

      test('Korean (Hangul syllables)', () {
        expect(
          codec.encoder.convert('세계의모든사람들이한국어를이해한다면얼마나좋을까'),
          '989aomsvi5e83db1d2a355cv1e0vak1dwrv93d5xbh15a0dt30a5jpsd879ccm6fea98c',
        );
      });

      // https://github.com/bivens-dev/rdf_dart/issues/13
      test('Russian (Cyrillic)', () {
        expect(
          codec.encoder.convert('почемужеонинеговорятпорусски'),
          'b1abfaaepdrnnbgefbadotcwatmq2g4l',
        );
      });

      test('Spanish', () {
        expect(
          codec.encoder.convert('PorquénopuedensimplementehablarenEspañol'),
          'PorqunopuedensimplementehablarenEspaol-fmd56a',
        );
      });

      test('Vietnamese', () {
        expect(
          codec.encoder.convert('TạisaohọkhôngthểchỉnóitiếngViệt'),
          'TisaohkhngthchnitingVit-kjcr8268qyxafd2f1b9g',
        );
      });

      test('3年B組金八先生', () {
        expect(
          codec.encoder.convert('3\u5E74B\u7D44\u91D1\u516B\u5148\u751F'),
          '3B-ww4c5e180e575a65lsy2b',
        );
      });

      test('安室奈美恵-with-SUPER-MONKEYS', () {
        expect(
          codec.encoder.convert(
            '\u5B89\u5BA4\u5948\u7F8E\u6075-with-SUPER-MONKEYS',
          ),
          '-with-SUPER-MONKEYS-pc58ag80a8qai00g7n9n',
        );
      });

      test('Hello-Another-Way-それぞれの場所', () {
        expect(
          codec.encoder.convert(
            'Hello-Another-Way-\u305D\u308C\u305E\u308C\u306E\u5834\u6240',
          ),
          'Hello-Another-Way--fc4qua05auwb3674vfr0b',
        );
      });

      test('ひとつ屋根の下2', () {
        expect(
          codec.encoder.convert('\u3072\u3068\u3064\u5C4B\u6839\u306E\u4E0B2'),
          '2-u9tlzr9756bt3uc0v',
        );
      });

      test('MajiでKoiする5秒前', () {
        expect(
          codec.encoder.convert('Maji\u3067Koi\u3059\u308B5\u79D2\u524D'),
          'MajiKoi5-783gue6qz075azm5e',
        );
      });

      test('パフィーdeルンバ', () {
        expect(
          codec.encoder.convert('\u30D1\u30D5\u30A3\u30FCde\u30EB\u30F3\u30D0'),
          'de-jg4avhby1noc0d',
        );
      });

      test('そのスピードで', () {
        expect(
          codec.encoder.convert('\u305D\u306E\u30B9\u30D4\u30FC\u30C9\u3067'),
          'd9juau41awczczp',
        );
      });
    });
  });
}
