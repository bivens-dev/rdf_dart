import 'package:rdf_dart/src/punycode/punycode_codec.dart';
import 'package:test/test.dart';

void main() {
  group('PunycodeDecoder', () {
    late PunycodeCodec codec;

    setUp(() {
      codec = PunycodeCodec();
    });

    test('multiple non-ASCII characters', () {
      expect(codec.decoder.convert('4can8av2009b'), 'üëäö♥');
    });

    test('a single non-ASCII character', () {
      expect(codec.decoder.convert('tda'), 'ü');
    });

    test('a single basic code point', () {
      expect(codec.decoder.convert('Bach-'), 'Bach');
    });

    test('mix of ASCII and non-ASCII characters', () {
      expect(codec.decoder.convert('bcher-kva'), 'bücher');
    });

    test('long string with both ASCII and non-ASCII characters', () {
      expect(
        codec.decoder.convert(
          'Willst du die Blthe des frhen, die Frchte des spteren Jahres-x9e96lkal',
        ),
        'Willst du die Blüthe des frühen, die Früchte des späteren Jahres',
      );
    });

    // https://datatracker.ietf.org/doc/html/rfc3492#section-7.1
    group('Official RFC examples', () {
      test('Arabic (Egyptian)', () {
        expect(
          codec.decoder.convert('egbpdaj6bu4bxfgehfvwxn'),
          'ليهمابتكلموشعربي؟',
        );
      });

      test('Chinese (simplified)', () {
        expect(codec.decoder.convert('ihqwcrb4cv8a8dqg056pqjye'), '他们为什么不说中文');
      });

      test('Chinese (traditional)', () {
        expect(
          codec.decoder.convert('ihqwctvzc91f659drss3x8bo0yb'),
          '他們爲什麽不說中文',
        );
      });

      test('Czech', () {
        expect(
          codec.decoder.convert('Proprostnemluvesky-uyb24dma41a'),
          'Pročprostěnemluvíčesky',
        );
      });

      test('Hebrew', () {
        expect(
          codec.decoder.convert('4dbcagdahymbxekheh6e0a7fei0b'),
          'למההםפשוטלאמדבריםעברית',
        );
      });

      test('Hindi (Devanagari)', () {
        expect(
          codec.decoder.convert('i1baa7eci9glrd9b2ae1bj0hfcgg6iyaf8o0a1dig0cd'),
          'यहलोगहिन्दीक्योंनहींबोलसकतेहैं',
        );
      });

      test('Japanese (kanji and hiragana)', () {
        expect(
          codec.decoder.convert('n8jok5ay5dzabd5bym9f0cm5685rrjetr6pdxa'),
          'なぜみんな日本語を話してくれないのか',
        );
      });

      test('Korean (Hangul syllables)', () {
        expect(
          codec.decoder.convert(
            '989aomsvi5e83db1d2a355cv1e0vak1dwrv93d5xbh15a0dt30a5jpsd879ccm6fea98c',
          ),
          '세계의모든사람들이한국어를이해한다면얼마나좋을까',
        );
      });

      //  https://github.com/bivens-dev/rdf_dart/issues/13
      test('Russian (Cyrillic)', () {
        expect(
          codec.decoder.convert('b1abfaaepdrnnbgefbadotcwatmq2g4l'),
          'почемужеонинеговорятпорусски',
        );
      });

      test('Spanish', () {
        expect(
          codec.decoder.convert(
            'PorqunopuedensimplementehablarenEspaol-fmd56a',
          ),
          'PorquénopuedensimplementehablarenEspañol',
        );
      });

      test('Vietnamese', () {
        expect(
          codec.decoder.convert('TisaohkhngthchnitingVit-kjcr8268qyxafd2f1b9g'),
          'TạisaohọkhôngthểchỉnóitiếngViệt',
        );
      });

      test('3年B組金八先生', () {
        expect(
          codec.decoder.convert('3B-ww4c5e180e575a65lsy2b'),
          '3\u5E74B\u7D44\u91D1\u516B\u5148\u751F',
        );
      });

      test('安室奈美恵-with-SUPER-MONKEYS', () {
        expect(
          codec.decoder.convert('-with-SUPER-MONKEYS-pc58ag80a8qai00g7n9n'),
          '\u5B89\u5BA4\u5948\u7F8E\u6075-with-SUPER-MONKEYS',
        );
      });

      test('Hello-Another-Way-それぞれの場所', () {
        expect(
          codec.decoder.convert('Hello-Another-Way--fc4qua05auwb3674vfr0b'),
          'Hello-Another-Way-\u305D\u308C\u305E\u308C\u306E\u5834\u6240',
        );
      });

      test('ひとつ屋根の下2', () {
        expect(
          codec.decoder.convert('2-u9tlzr9756bt3uc0v'),
          '\u3072\u3068\u3064\u5C4B\u6839\u306E\u4E0B2',
        );
      });

      test('MajiでKoiする5秒前', () {
        expect(
          codec.decoder.convert('MajiKoi5-783gue6qz075azm5e'),
          'Maji\u3067Koi\u3059\u308B5\u79D2\u524D',
        );
      });

      test('パフィーdeルンバ', () {
        expect(
          codec.decoder.convert('de-jg4avhby1noc0d'),
          '\u30D1\u30D5\u30A3\u30FCde\u30EB\u30F3\u30D0',
        );
      });

      test('そのスピードで', () {
        expect(
          codec.decoder.convert('d9juau41awczczp'),
          '\u305D\u306E\u30B9\u30D4\u30FC\u30C9\u3067',
        );
      });
    });
  });
}
