import 'package:punycode_codec/punycode_codec.dart';

void main() {
  // Use the singleton encoder and decoder instances
  // for domain/email specific operations which handle the 'xn--' prefix.
  const encoder = punycodeEncoder;
  const decoder = punycodeDecoder;

  // --- Example 1: Converting potential IDNs to ASCII (ACE format) ---
  print('--- Converting Domains/Emails to ASCII ---');
  final potentialIdns = [
    'example.com',         // Pure ASCII domain
    'bücher.example',      // German domain label
    '你好世界.test',       // Chinese domain label
    'xn--maana-pta.com',  // Already Punycode encoded domain
    'test@example.com',    // Pure ASCII email
    'josé@bücher.example', // Email with Unicode local part and domain part
    '💩.la',              // Emoji domain
  ];

  for (final item in potentialIdns) {
    try {
      // toAscii intelligently encodes only the domain part(s) if needed
      // and adds the 'xn--' prefix where necessary.
      final asciiVersion = encoder.toAscii(item);
      print('"$item"  ->  "$asciiVersion"');
    } catch (e) {
      print('Could not encode "$item": $e');
      // Note: Full IDNA compliance also requires Nameprep normalization
      // before Punycode encoding. This example focuses on Punycode.
    }
  }
  print('--------------------\n' );

  // --- Example 2: Converting ACE strings back to Unicode ---
  print('--- Converting ACE Domains/Emails to Unicode ---');
  final aceStrings = [
    'example.com',                     // Pure ASCII domain
    'xn--bcher-kva.example',          // Encoded German domain label
    'xn--fsqu00a.test',               // Encoded Chinese domain label
    'xn--maana-pta.com',              // Already Punycode (will be decoded)
    'test@example.com',                // Pure ASCII email
    'josé@xn--bcher-kva.example',     // Email with Unicode local part and encoded domain
    'xn--ls8h.la',                    // Encoded Emoji domain
  ];

  for (final item in aceStrings) {
    try {
      // toUnicode intelligently decodes only the ACE parts (starting with 'xn--')
      // of the domain portion of the string.
      final unicodeVersion = decoder.toUnicode(item);
      print('"$item"  ->  "$unicodeVersion"');
    } catch (e) {
      print('Could not decode "$item": $e');
    }
  }
  print('--------------------\n' );

  // --- Example 3: Raw Punycode vs IDNA Helpers ---
  print('--- Raw Encoding/Decoding (Manual Prefix Handling) ---');
  // Use the base codec for raw conversion without automatic prefix handling.
  final codec = PunycodeCodec();
  final unicodeLabel = 'bücher';
  final expectedAceLabel = 'xn--bcher-kva';

  // Raw encoding (suitable for a single label, no prefix added)
  final rawEncodedLabel = codec.encode(unicodeLabel);
  print('Raw encode: "$unicodeLabel" -> "$rawEncodedLabel"'); // Output: bcher-kva

  // Raw decoding (expects input without prefix)
  // To decode an ACE label, first remove the prefix.
  if (expectedAceLabel.startsWith('xn--')) {
    final punycodePart = expectedAceLabel.substring(4);
    final rawDecodedLabel = codec.decode(punycodePart);
    print('Raw decode: "$punycodePart" -> "$rawDecodedLabel"'); // Output: bücher
  }
  print('--------------------');
}