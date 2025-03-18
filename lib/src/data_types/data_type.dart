import 'package:meta/meta.dart';

/// Represents an RDF datatype.
///
/// An RDF datatype defines a mapping between lexical representations (strings)
/// and values. It's fundamentally characterized by three components:
///
/// 1.  **Lexical Space:** The set of all valid string representations for
///     values of this datatype.  For example, for `xsd:boolean`, this would
///     be the set { "true", "false", "1", "0" }.
/// 2.  **Value Space:** The set of all possible values that this datatype
///     can represent. For `xsd:boolean`, this is the set { true, false }.
/// 3.  **Lexical-to-Value Mapping:**  A mapping that associates each string in
///     the lexical space with *exactly one* value in the value space.  This
///     mapping is *many-to-one*; multiple lexical forms can map to the same
///     value (e.g., "1" and "true" for `xsd:boolean`).
///
/// Each RDF datatype is identified by an IRI.  For example, the IRI for
/// the XML Schema boolean datatype is `http://www.w3.org/2001/XMLSchema#boolean`.
///
/// This abstract class provides a common interface for defining and working
/// with RDF datatypes in Dart.  Concrete subclasses implement the specific
/// mappings for particular datatypes.
///
/// See also:
/// *   [RDF 1.2 Concepts and Abstract Syntax, Section 5: Datatypes](https://www.w3.org/TR/rdf12-concepts/#section-Datatypes)
@immutable
abstract class RDFDataType<T> {
  /// The IRI that identifies this datatype.
  ///
  /// This IRI is used to uniquely identify the datatype in RDF graphs.
  final String iri;

  /// Creates a new [RDFDataType] with the given identifying [iri].
  const RDFDataType(this.iri);

  /// Converts a [lexicalForm] (a string) to its corresponding value.
  ///
  /// This method implements the *lexical-to-value mapping* for the datatype.
  ///
  /// Throws a [FormatException] if the given [lexicalForm] is not a valid
  /// member of the datatype's lexical space (i.e., it's not a valid
  /// string representation for this datatype).
  T lexicalToValue(String lexicalForm);

  /// Converts a [value] to its *canonical* lexical representation (a string).
  ///
  /// The canonical representation is a preferred or standard string
  /// representation for a given value.  Not all datatypes have a
  /// well-defined canonical representation.
  ///
  /// Returns `null` if a canonical representation is not defined or cannot
  /// be determined for the given [value]. It is important to note this is
  /// distinct from the *absence* of a lexical representation, but the
  /// inability to provide a standard one.
  String? valueToLexical(T value);

  /// Checks whether a given [lexicalForm] is a valid string representation
  /// for this datatype.
  ///
  /// This method provides a way to test the validity of a lexical form
  /// without incurring the overhead of actually converting it to a value.
  /// It's equivalent to calling [lexicalToValue] and catching any
  /// [FormatException], but may be more efficient.
  bool isValidLexicalForm(String lexicalForm) {
    try {
      lexicalToValue(lexicalForm);
      return true;
    } on FormatException {
      return false;
    }
  }

  /// Determines whether two datatypes are considered identical.
  ///
  /// Two datatypes are identical if and only if their identifying IRIs are
  /// equal. This reflects the RDF specification's use of IRIs for datatype
  /// identification.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is RDFDataType) {
      return iri == other.iri;
    }
    return false;
  }

  @override
  int get hashCode => iri.hashCode;

  @override
  String toString() => iri;
}
