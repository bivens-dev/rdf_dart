import 'package:iri/iri.dart';

void main() {
  final iri = IRI('https://例子.com/pȧth?q=1');
  print(iri);
  final encodedUri = iri.toUri();
  print(encodedUri);
}
