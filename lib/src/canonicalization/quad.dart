import 'package:rdf_dart/src/iri_term.dart';
import 'package:rdf_dart/src/rdf_term.dart';
import 'package:rdf_dart/src/subject_type.dart';

/// Represents an RDF Quad (subject, predicate, object, graphLabel)
/// used internally during canonicalization.
/// GraphLabel is null for quads in the default graph.
typedef Quad = ({
  SubjectTerm subject,
  IRITerm predicate,
  RdfTerm object,
  SubjectTerm? graphLabel,
});