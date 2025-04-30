import 'package:punycode_codec/punycode_codec.dart';

void main() {
  final codec = PunycodeCodec();
  final encodedString = codec.encoder.convert('ليهمابتكلموشعربي؟');
  print(encodedString);

  final decodedString = codec.decoder.convert('ihqwcrb4cv8a8dqg056pqjye');
  print(decodedString);
}
