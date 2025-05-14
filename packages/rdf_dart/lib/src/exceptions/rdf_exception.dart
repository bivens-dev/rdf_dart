/// Base class for exceptions specific to the RDF Dart library.
///
/// This class serves as the root for all custom exceptions thrown by this
/// library, allowing users to catch all RDF-related issues with a single
/// `catch (RDFException)`.
class RDFException implements Exception {
  /// A message describing the specific exception that occurred.
  final String message;

  /// Creates a new [RDFException] with the given [message].
  RDFException(this.message);

  @override
  String toString() => 'RDFException: $message';
}
