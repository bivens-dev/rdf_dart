import 'package:rdf_dart/rdf_dart.dart';

void main() {
  var iri = IRI('http://example.com /path');
  
  print('url: $iri');

  print(IRI('http://www.example.com/r\u00e9sum\u00e9'));
}
