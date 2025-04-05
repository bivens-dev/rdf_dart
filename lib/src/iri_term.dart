import 'package:meta/meta.dart';
import 'package:rdf_dart/src/rdf_term.dart';
import 'package:rdf_dart/src/term_type.dart';

/// Represents an Internationalized Resource Identifier (IRI).
///
/// An IRI is a string that identifies a resource. This class ensures that the
/// provided IRI string conforms to the basic IRI syntax rules. While this class
/// performs basic validation, it doesn't check whether the resource referred to
/// by the IRI actually exists.
///
/// This class is immutable. Once an IRI object is created, its value cannot
/// be changed.
@immutable
class IRITerm extends RdfTerm {
  /// The string value of this IRI.
  final String value;

  /// Creates a new IRI from the given [value] string.
  ///
  /// The [value] string is validated to ensure it conforms to basic IRI
  /// syntax rules. If the string is not a valid IRI, an
  /// [FormatException] is thrown.
  ///
  /// If the IRI is valid, the string is parsed and any necessary percent-encoding
  /// is applied to create a normalized IRI string.
  ///
  /// Example:
  /// ```dart
  /// final validIri = IRI('http://example.com/resource');
  /// print(validIri.value); // Output: http://example.com/resource
  ///
  /// try {
  ///   final invalidIri = IRI('http://example.com /resource');
  /// } on InvalidIRIException catch (e) {
  ///   print(e); // Output: FormatException
  /// }
  /// ```
  IRITerm(String value) : value = _validateIri(value);

  /// Validates the given [unvalidatedIri] string and returns a valid IRI string.
  ///
  /// If the [unvalidatedIri] string is a valid IRI, it is parsed using
  /// [Uri.parse] and any necessary percent-encoding is applied. The resulting
  /// normalized IRI string is then returned. However, be aware this class does
  /// not currently do a full translation between IRIs and URIs as per the spec
  ///
  /// If the [unvalidatedIri] string is not a valid IRI, an
  /// [FormatException] is thrown.
  static String _validateIri(String unvalidatedIri) {
    if (!_isValidIRI(unvalidatedIri)) {
      throw FormatException(
        'Does not match the lexical space value: $unvalidatedIri',
      );
    }

    if (unvalidatedIri.isEmpty) {
      throw FormatException('IRI cannot be empty');
    }

    // TODO: Figure out the proper mapping between IRI and URIs but will
    // almost certainly continue to use Uri as the underlying data type

    final validatedUri = Uri.parse(unvalidatedIri);

    return validatedUri.toString();
  }

  static bool _isValidIRI(String input) {
    const scheme = r'[a-zA-Z][a-zA-Z0-9+\-.]*';
    const ucschar =
        r'[\u{a0}-\u{d7ff}\u{f900}-\u{fdcf}\u{fdf0}-\u{ffef}\u{10000}-\u{1fffd}\u{20000}-\u{2fffd}\u{30000}-\u{3fffd}\u{40000}-\u{4fffd}\u{50000}-\u{5fffd}\u{60000}-\u{6fffd}\u{70000}-\u{7fffd}\u{80000}-\u{8fffd}\u{90000}-\u{9fffd}\u{a0000}-\u{afffd}\u{b0000}-\u{bfffd}\u{c0000}-\u{cfffd}\u{d0000}-\u{dfffd}\u{e1000}-\u{efffd}]';
    const iunreserved = '([a-zA-Z0-9\\-._~]|$ucschar)';
    const pctEncoded = '%[0-9A-Fa-f][0-9A-Fa-f]';
    const subDelims = r"[!$&'()*+,;=]";
    const iuserinfo = '($iunreserved|$pctEncoded|$subDelims|:)*';
    const h16 = '[0-9A-Fa-f]{1,4}';
    const decOctet = '([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])';
    const ipv4address = '$decOctet\\.$decOctet\\.$decOctet\\.$decOctet';
    const ls32 = '($h16:$h16|$ipv4address)';
    const ipv6address =
        '(($h16:){6}$ls32|::($h16:){5}$ls32|($h16)?::($h16:){4}$ls32|(($h16:)?$h16)?::($h16:){3}$ls32|(($h16:){0,2}$h16)?::($h16:){2}$ls32|(($h16:){0,3}$h16)?::$h16:$ls32|(($h16:){0,4}$h16)?::$ls32|(($h16:){0,5}$h16)?::$h16|(($h16:){0,6}$h16)?::)';
    const unreserved = r'[a-zA-Z0-9\-._~]';
    const ipvfuture = '[vV][0-9A-Fa-f]+\\.($unreserved|$subDelims|:)+';
    const ipLiteral = '\\[($ipv6address|$ipvfuture)\\]';
    const iregName = '($iunreserved|$pctEncoded|$subDelims)*';
    const ihost = '($ipLiteral|$ipv4address|$iregName)';
    const port = '[0-9]*';
    const iauthority = '($iuserinfo@)?$ihost(:$port)?';
    const ipchar = '($iunreserved|$pctEncoded|$subDelims|[:@])';
    const isegment = '($ipchar)*';
    const ipathAbempty = '(/$isegment)*';
    const isegmentNz = '($ipchar)+';
    const ipathAbsolute = '/($isegmentNz(/$isegment)*)?';
    const ipathRootless = '$isegmentNz(/$isegment)*';
    const ipathEmpty = '($ipchar){0}';
    const ihierPart =
        '(//$iauthority$ipathAbempty|$ipathAbsolute|$ipathRootless|$ipathEmpty)';
    const iprivate =
        r'[\u{e000}-\u{f8ff}\u{f0000}-\u{ffffd}\u{100000}-\u{10fffd}]';
    const iquery = '($ipchar|$iprivate|[/?])*';
    const ifragment = '($ipchar|[/?])*';
    const isegmentNzNc = '($iunreserved|$pctEncoded|$subDelims|@)+';
    const ipathNoscheme = '$isegmentNzNc(/$isegment)*';
    const irelativePart =
        '(//$iauthority$ipathAbempty|$ipathAbsolute|$ipathNoscheme|$ipathEmpty)';
    const irelativeRef = '$irelativePart(\\?$iquery)?(#$ifragment)?';
    const iri = '$scheme:$ihierPart(\\?$iquery)?(#$ifragment)?';
    const iriReference = '($iri|$irelativeRef)';
    const pattern = '^$iriReference\$';
    final regex = RegExp(pattern, unicode: true);
    return regex.hasMatch(input);
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
  bool operator ==(Object other) => other is IRITerm && value == other.value;
}
