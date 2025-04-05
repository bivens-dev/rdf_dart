import 'package:meta/meta.dart';
import 'package:rdf_dart/src/punycode/punycode_codec.dart';

/// Represents an Internationalized Resource Identifier (IRI) according to RFC 3987.
///
/// This class focuses on the parsing, validation, component access, normalization,
/// and URI conversion of IRIs.
@immutable
class IRI {
  final Uri _encodedUri;

  final PunycodeCodec _punycodeCodec = PunycodeCodec();

  IRI(String originalValue) : _encodedUri = _convertToUri(originalValue);

  // Component Accessors
  String get scheme => _encodedUri.scheme;
  String get authority => _encodedUri.authority;
  String get userInfo => _encodedUri.userInfo;
  String get host {
    // The host component of a URI is encoded using Punycode. We need to decode it.
    // Note that strings that are not encoded using Punycode will be returned as-is.
    return _punycodeCodec.decoder.convert(_encodedUri.host);
  }
  String get path => _encodedUri.path;
  String get fragment => _encodedUri.fragment;
  String get query => _encodedUri.query;
  int get port => _encodedUri.port;

  bool get hasScheme => scheme.isNotEmpty;

  bool get hasAuthority => host.isNotEmpty;

  bool get hasPort => port == 0;

  bool get hasQuery => query.isNotEmpty;

  bool get hasFragment => fragment.isNotEmpty;

  bool get hasEmptyPath => path.isEmpty;

  bool get hasAbsolutePath => path.startsWith('/');

  Uri toUri(){
    return _encodedUri;
  }

  static bool _isValid(String input) {
    final pattern = '^${_IRIRegexHelper.patterns.iriReference}\$';
    final regex = RegExp(pattern, unicode: true);
    return regex.hasMatch(input);
  }

  /// A function which takes a String, confirms it is a valid IRI and returns
  /// it encoded as a URI as per the RFC 3987 spec.
  static Uri _convertToUri(String iri) {
    // Make sure the value is a valid IRI to begin with
    if (!_isValid(iri)) {
      throw FormatException('Invalid IRI: $iri');
    }

    // Next check to see if it is *already* a URI without further processing
    final simpleUri = Uri.tryParse(iri);
    if (simpleUri != null) {
      return simpleUri.normalizePath();
    }

    // If we make it here we need to do some more complex IRI to URI conversion
    throw UnimplementedError('Complex IRI conversion not implemented yet');
  }

  @override
  int get hashCode {
    // Compute hash code based on the *normalized* components.
    return _encodedUri.hashCode;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! IRI) return false;
    // TODO: There is a proper way of doing this using unicode normalization but this is easier for now
    return _encodedUri == other._encodedUri;
  }

  @override
  String toString() {
    return '$scheme:$authority$path${hasQuery ? '?$query' : ''}${hasFragment ? '#$fragment' : ''}';
  }
}

// ignore: avoid_classes_with_only_static_members
/// Regular expressions for IRI components
/// The following rules are different from those in [RFC3986]:
///
/// ```abnf
/// IRI            = scheme ":" ihier-part [ "?" iquery ]
///                       [ "#" ifragment ]
///
/// ihier-part     = "//" iauthority ipath-abempty
///                / ipath-absolute
///                / ipath-rootless
///                / ipath-empty
///
/// IRI-reference  = IRI / irelative-ref
///
/// absolute-IRI   = scheme ":" ihier-part [ "?" iquery ]
///
/// irelative-ref  = irelative-part [ "?" iquery ] [ "#" ifragment ]
///
/// irelative-part = "//" iauthority ipath-abempty
///                     / ipath-absolute
///                   / ipath-noscheme
///                / ipath-empty
///
/// iauthority     = [ iuserinfo "@" ] ihost [ ":" port ]
/// iuserinfo      = *( iunreserved / pct-encoded / sub-delims / ":" )
/// ihost          = IP-literal / IPv4address / ireg-name
///
/// ireg-name      = *( iunreserved / pct-encoded / sub-delims )
///
/// ipath          = ipath-abempty   ; begins with "/" or is empty
///                / ipath-absolute  ; begins with "/" but not "//"
///                / ipath-noscheme  ; begins with a non-colon segment
///                / ipath-rootless  ; begins with a segment
///                / ipath-empty     ; zero characters
///
/// ipath-abempty  = *( "/" isegment )
/// ipath-absolute = "/" [ isegment-nz *( "/" isegment ) ]
/// ipath-noscheme = isegment-nz-nc *( "/" isegment )
/// ipath-rootless = isegment-nz *( "/" isegment )
/// ipath-empty    = 0<ipchar>
///
/// isegment       = *ipchar
/// isegment-nz    = 1*ipchar
/// isegment-nz-nc = 1*( iunreserved / pct-encoded / sub-delims
///                      / "@" )
///                ; non-zero-length segment without any colon ":"
///
/// ipchar         = iunreserved / pct-encoded / sub-delims / ":"
///                / "@"
///
/// iquery         = *( ipchar / iprivate / "/" / "?" )
///
/// ifragment      = *( ipchar / "/" / "?" )
///
/// iunreserved    = ALPHA / DIGIT / "-" / "." / "_" / "~" / ucschar
///
/// ucschar        = %xA0-D7FF / %xF900-FDCF / %xFDF0-FFEF
///                / %x10000-1FFFD / %x20000-2FFFD / %x30000-3FFFD
///                / %x40000-4FFFD / %x50000-5FFFD / %x60000-6FFFD
///                / %x70000-7FFFD / %x80000-8FFFD / %x90000-9FFFD
///                / %xA0000-AFFFD / %xB0000-BFFFD / %xC0000-CFFFD
///                / %xD0000-DFFFD / %xE1000-EFFFD
///
/// iprivate       = %xE000-F8FF / %xF0000-FFFFD / %x100000-10FFFD
///```
///
/// Some productions are ambiguous.  The "first-match-wins" (a.k.a.
/// "greedy") algorithm applies.  For details, see [RFC3986].
///
/// The following rules are the same as those in [RFC3986]:
/// ```abnf
///    scheme         = ALPHA *( ALPHA / DIGIT / "+" / "-" / "." )
///
/// port           = *DIGIT
///
/// IP-literal     = "[" ( IPv6address / IPvFuture  ) "]"
///
/// IPvFuture      = "v" 1*HEXDIG "." 1*( unreserved / sub-delims / ":" )
///
/// IPv6address    =                            6( h16 ":" ) ls32
///                /                       "::" 5( h16 ":" ) ls32
///                / [               h16 ] "::" 4( h16 ":" ) ls32
///                / [ *1( h16 ":" ) h16 ] "::" 3( h16 ":" ) ls32
///                / [ *2( h16 ":" ) h16 ] "::" 2( h16 ":" ) ls32
///                / [ *3( h16 ":" ) h16 ] "::"    h16 ":"   ls32
///                / [ *4( h16 ":" ) h16 ] "::"              ls32
///                / [ *5( h16 ":" ) h16 ] "::"              h16
///                / [ *6( h16 ":" ) h16 ] "::"
///
/// h16            = 1*4HEXDIG
/// ls32           = ( h16 ":" h16 ) / IPv4address
///
/// IPv4address    = dec-octet "." dec-octet "." dec-octet "." dec-octet
///
/// dec-octet      = DIGIT                 ; 0-9
///                / %x31-39 DIGIT         ; 10-99
///                / "1" 2DIGIT            ; 100-199
///                / "2" %x30-34 DIGIT     ; 200-249
///                / "25" %x30-35          ; 250-255
///
/// pct-encoded    = "%" HEXDIG HEXDIG
///
/// unreserved     = ALPHA / DIGIT / "-" / "." / "_" / "~"
/// reserved       = gen-delims / sub-delims
/// gen-delims     = ":" / "/" / "?" / "#" / "[" / "]" / "@"
/// sub-delims     = "!" / "$" / "&" / "'" / "(" / ")"
///                / "*" / "+" / "," / ";" / "="
/// ```
class _IRIRegexHelper {
  static const String _scheme = r'[a-zA-Z][a-zA-Z0-9+\-.]*';
  static const String _ucschar =
      r'[\u{a0}-\u{d7ff}\u{f900}-\u{fdcf}\u{fdf0}-\u{ffef}\u{10000}-\u{1fffd}\u{20000}-\u{2fffd}\u{30000}-\u{3fffd}\u{40000}-\u{4fffd}\u{50000}-\u{5fffd}\u{60000}-\u{6fffd}\u{70000}-\u{7fffd}\u{80000}-\u{8fffd}\u{90000}-\u{9fffd}\u{a0000}-\u{afffd}\u{b0000}-\u{bfffd}\u{c0000}-\u{cfffd}\u{d0000}-\u{dfffd}\u{e1000}-\u{efffd}]';
  static const String _iunreserved = '([a-zA-Z0-9\\-._~]|$_ucschar)';
  static const String _pctEncoded = '%[0-9A-Fa-f][0-9A-Fa-f]';
  static const String _subDelims = r"[!$&'()*+,;=]";
  static const String _iuserinfo =
      '($_iunreserved|$_pctEncoded|$_subDelims|:)*';
  static const String _h16 = '[0-9A-Fa-f]{1,4}';
  static const String _decOctet =
      '([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])';
  static const String _ipv4address =
      '$_decOctet\\.$_decOctet\\.$_decOctet\\.$_decOctet';
  static const String _ls32 = '($_h16:$_h16|$_ipv4address)';
  static const String _ipv6address =
      '(($_h16:){6}$_ls32|::($_h16:){5}$_ls32|($_h16)?::($_h16:){4}$_ls32|(($_h16:)?$_h16)?::($_h16:){3}$_ls32|(($_h16:){0,2}$_h16)?::($_h16:){2}$_ls32|(($_h16:){0,3}$_h16)?::$_h16:$_ls32|(($_h16:){0,4}$_h16)?::$_ls32|(($_h16:){0,5}$_h16)?::$_h16|(($_h16:){0,6}$_h16)?::)';
  static const String _unreserved = r'[a-zA-Z0-9\-._~]';
  static const String _ipvfuture =
      '[vV][0-9A-Fa-f]+\\.($_unreserved|$_subDelims|:)+';
  static const String _ipLiteral = '\\[($_ipv6address|$_ipvfuture)\\]';
  static const String _iregName = '($_iunreserved|$_pctEncoded|$_subDelims)*';
  static const String _ihost = '($_ipLiteral|$_ipv4address|$_iregName)';
  static const String _port = '[0-9]*';
  static const String _iauthority = '($_iuserinfo@)?$_ihost(:$_port)?';
  static const String _ipchar = '($_iunreserved|$_pctEncoded|$_subDelims|[:@])';
  static const String _isegment = '($_ipchar)*';
  static const String _ipathAbempty = '(/$_isegment)*';
  static const String _isegmentNz = '($_ipchar)+';
  static const String _ipathAbsolute = '/($_isegmentNz(/$_isegment)*)?';
  static const String _ipathRootless = '$_isegmentNz(/$_isegment)*';
  static const String _ipathEmpty = '($_ipchar){0}';
  static const String _ihierPart =
      '(//$_iauthority$_ipathAbempty|$_ipathAbsolute|$_ipathRootless|$_ipathEmpty)';
  static const String _iprivate =
      r'[\u{e000}-\u{f8ff}\u{f0000}-\u{ffffd}\u{100000}-\u{10fffd}]';
  static const String _iquery = '($_ipchar|$_iprivate|[/?])*';
  static const String _ifragment = '($_ipchar|[/?])*';
  static const String _isegmentNzNc =
      '($_iunreserved|$_pctEncoded|$_subDelims|@)+';
  static const String _ipathNoscheme = '$_isegmentNzNc(/$_isegment)*';
  static const String _irelativePart =
      '(//$_iauthority$_ipathAbempty|$_ipathAbsolute|$_ipathNoscheme|$_ipathEmpty)';
  static const String _irelativeRef =
      '$_irelativePart(\\?$_iquery)?(#$_ifragment)?';
  static const String _iri =
      '$_scheme:$_ihierPart(\\?$_iquery)?(#$_ifragment)?';
  static const String _iriReference = '($_iri|$_irelativeRef)';

  static final patterns = (
    scheme: _scheme,
    ucschar: _ucschar,
    iunreserved: _iunreserved,
    pctEncoded: _pctEncoded,
    subDelims: _subDelims,
    iuserinfo: _iuserinfo,
    h16: _h16,
    decOctet: _decOctet,
    ipv4address: _ipv4address,
    ls32: _ls32,
    ipv6address: _ipv6address,
    unreserved: _unreserved,
    ipvfuture: _ipvfuture,
    ipLiteral: _ipLiteral,
    iregName: _iregName,
    ihost: _ihost,
    port: _port,
    iauthority: _iauthority,
    ipchar: _ipchar,
    isegment: _isegment,
    ipathAbempty: _ipathAbempty,
    isegmentNz: _isegmentNz,
    ipathAbsolute: _ipathAbsolute,
    ipathRootless: _ipathRootless,
    ipathEmpty: _ipathEmpty,
    ihierPart: _ihierPart,
    iprivate: _iprivate,
    iquery: _iquery,
    ifragment: _ifragment,
    isegmentNzNc: _isegmentNzNc,
    ipathNoscheme: _ipathNoscheme,
    irelativePart: _irelativePart,
    irelativeRef: _irelativeRef,
    iri: _iri,
    iriReference: _iriReference,
  );
}
