import 'dart:convert';

import 'package:rdf_dart/src/dataset.dart';

class NQuadsCodec extends Codec<Dataset, String> {
  /// Creates an N-Quads codec.
  const NQuadsCodec();

  @override
  Converter<Dataset, String> get encoder => throw UnimplementedError();

  @override
  Converter<String, Dataset> get decoder => throw UnimplementedError();
}

/// Constant instance of the default [NQuadsCodec].
const nQuadsCodec = NQuadsCodec();
