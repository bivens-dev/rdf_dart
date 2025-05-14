import 'package:rdf_dart/src/model/iri_node.dart';
import 'package:rdf_dart/src/model/rdf_term.dart';
import 'package:rdf_dart/src/model/subject_type.dart';

/// Represents an RDF Quad (subject, predicate, object, graphLabel)
/// GraphLabel is null for quads in the default graph.
typedef Quad =
    ({
      SubjectTerm subject,
      IRINode predicate,
      RdfTerm object,
      SubjectTerm? graphLabel,
    });
