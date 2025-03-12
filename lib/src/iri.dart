import 'package:rdf_dart/src/rdf_term.dart';
import 'package:rdf_dart/src/term_type.dart';

class InvalidIRIException implements Exception {
  final String message;
  InvalidIRIException(this.message);
  @override
  String toString() => 'InvalidIRIException: $message';
}

class IRI extends RdfTerm {
  final String value;

  IRI(String value) : value = _validateIri(value);

  static String _validateIri(String unvalidatedIri) {
    try {
      // TODO: Use more robut IRI validation here in the future but URI.parse is sufficient for now.
      final validatedUri = Uri.parse(unvalidatedIri);
      return validatedUri.toString();
    } on FormatException catch (e) {
      throw InvalidIRIException(
        'Invalid IRI: $unvalidatedIri - Error: ${e.message}',
      );
    }
  }

  @override
  bool get isIRI => true;

  @override
  bool get isBlankNode => false;

  @override
  bool get isLiteral => false;

  @override
  TermType get termType => TermType.iri;

  @override
  String toString() => value;

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) => other is IRI && value == other.value;
}
