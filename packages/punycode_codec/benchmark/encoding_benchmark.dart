// Import BenchmarkBase class.
import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:punycode_codec/punycode_codec.dart';

final punycodeCodec = PunycodeCodec();

// Create a new benchmark by extending BenchmarkBase
class EncodingBenchmark extends BenchmarkBase {
  late final List<String> unicodeStringList;

  final listSize = 100;

  EncodingBenchmark() : super('Encoding');

  static void main() {
    EncodingBenchmark().report();
  }

  // Encode 100 unicode strings
  @override
  void run() {
    for (var unicodeString in unicodeStringList) {
      punycodeCodec.encoder.convert(unicodeString);
    }
  }

  // Not measured setup code executed prior to the benchmark runs.
  @override
  void setup() {
    unicodeStringList = List.generate(listSize, (i) => _createUnicodeString());
  }

  // Not measured teardown code executed after the benchmark runs.
  @override
  void teardown() {}

  String _createUnicodeString() {
    final baseCharacters = 'なぜみんな日本語を話してくれないのかليهمابتكلموشعربي؟他们为什么不说中文';
    final random = Random();
    final stringLength = 15;
    final unicodeString = StringBuffer();

    for (var i = 0; i < stringLength; i++) {
      unicodeString.write(
        baseCharacters[random.nextInt(baseCharacters.length)],
      );
    }
    return unicodeString.toString();
  }
}

void main() {
  // Run EncodingBenchmark
  EncodingBenchmark.main();
}
