import 'package:rdf_dart/src/iri.dart';

/// Provides constants for the RDF vocabulary namespace (rdf:).
///
/// This namespace includes fundamental concepts of the RDF model like
/// types, properties, list structures, reification, and datatypes.
///
/// See: https://www.w3.org/TR/rdf12-concepts/
/// See: https://www.w3.org/TR/rdf12-schema/
final class RDF {
  /// The base namespace for the RDF vocabulary.
  static const String namespace = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#';

  // --- Classes ---

  /// `rdf:Property` - The class of RDF properties.
  static final IRI property = IRI('${namespace}Property');

  /// `rdf:Statement` - The class of RDF statements (used for reification).
  static final IRI statement = IRI('${namespace}Statement');

  /// `rdf:List` - The class of RDF Lists.
  static final IRI list = IRI('${namespace}List'); // Renamed

  /// `rdf:Seq` - The class of ordered sequences (RDF containers).
  static final IRI seq = IRI('${namespace}Seq');

  /// `rdf:Bag` - The class of unordered bags (RDF containers).
  static final IRI bag = IRI('${namespace}Bag');

  /// `rdf:Alt` - The class of alternatives (RDF containers).
  static final IRI alt = IRI('${namespace}Alt');

  /// `rdf:CompoundLiteral` - The class of Compound Literals (RDF 1.2).
  /// Represents literals with both language and direction.
  static final IRI compoundLiteral = IRI('${namespace}CompoundLiteral');

  // --- Properties ---

  /// `rdf:type` - The subject is an instance of a class.
  static final IRI type = IRI('${namespace}type');

  /// `rdf:subject` - The subject of the RDF statement in reification.
  static final IRI subject = IRI('${namespace}subject');

  /// `rdf:predicate` - The predicate of the RDF statement in reification.
  static final IRI predicate = IRI('${namespace}predicate');

  /// `rdf:object` - The object of the RDF statement in reification.
  static final IRI object = IRI('${namespace}object');

  /// `rdf:first` - The first item in an RDF list.
  static final IRI first = IRI('${namespace}first');

  /// `rdf:rest` - The rest of the RDF list (another list or rdf:nil).
  static final IRI rest = IRI('${namespace}rest');

  /// `rdf:value` - Idiomatic property used for structured values.
  static final IRI value = IRI('${namespace}value');

  /// `rdf:language` - The base language component of an rdf:CompoundLiteral (RDF 1.2).
  static final IRI language = IRI('${namespace}language');

  /// `rdf:direction` - The base direction component of an rdf:CompoundLiteral (RDF 1.2).
  static final IRI direction = IRI('${namespace}direction');

  /// `rdf:reifies` - Relates a triple term object to its reification subject (RDF 1.2).
  /// See: https://www.w3.org/TR/rdf12-concepts/#section-triple-terms
  static final IRI reifies = IRI('${namespace}reifies');

  // --- Instances ---

  /// `rdf:nil` - The empty list.
  static final IRI nil = IRI('${namespace}nil');

  // --- Datatypes ---

  /// `rdf:langString` - The datatype of language-tagged string literals.
  static final IRI langString = IRI('${namespace}langString');

  /// `rdf:HTML` - The datatype for HTML content as a literal.
  static final IRI html = IRI('${namespace}HTML');

  /// `rdf:XMLLiteral` - The datatype for well-formed XML content as a literal.
  static final IRI xmlLiteral = IRI('${namespace}XMLLiteral');

  /// `rdf:JSON` - The datatype for JSON content as a literal (RDF 1.2).
  static final IRI json = IRI('${namespace}JSON');

  /// `rdf:TripleTerm` - The datatype for triple terms (RDF 1.2).
  static final IRI tripleTerm = IRI('${namespace}TripleTerm');

  /// `rdf:ttSubject` - The subject of a triple term (RDF 1.2).
  static final IRI ttSubject = IRI('${namespace}ttSubject');

  /// `rdf:ttPredicate` - The predicate of a triple term (RDF 1.2).
  static final IRI ttPredicate = IRI('${namespace}ttPredicate');

  /// `rdf:ttObject` - The object of a triple term (RDF 1.2).
  static final IRI ttObject = IRI('${namespace}ttObject');

  /// Private constructor to prevent instantiation.
  RDF._();
}
