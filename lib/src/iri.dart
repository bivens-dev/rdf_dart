import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rdf_dart/src/punycode/punycode_codec.dart';

/// Represents an Internationalized Resource Identifier (IRI) according to RFC 3987.
///
/// This class focuses on the parsing, validation, component access, normalization,
/// and URI conversion of IRIs.
@immutable
class IRI {
  final Uri _encodedUri;

  static final PunycodeCodec _punycodeCodec = PunycodeCodec();

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

  bool get hasPort => _encodedUri.hasPort;

  bool get hasQuery => query.isNotEmpty;

  bool get hasFragment => fragment.isNotEmpty;

  bool get hasEmptyPath => path.isEmpty;

  bool get hasAbsolutePath => path.startsWith('/');

  Uri toUri() {
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

    final normalizedComponents = _parseAndNormalize(iri);
    final scheme = normalizedComponents['scheme'] as String?;
    final userInfo = normalizedComponents['userInfo'] as String?;
    final host = normalizedComponents['host'] as String?;
    final port = normalizedComponents['port'] as int?;
    final path = normalizedComponents['path'] as String;
    final query = normalizedComponents['query'] as String?;
    final fragment = normalizedComponents['fragment'] as String?;

    // If we have a scheme and no authority, we can just return a URI with the scheme and path
    if (scheme != null && host == null) {
      return Uri(scheme: scheme, path: path, query: query, fragment: fragment);
    }

    // If we have a scheme and authority, we need to encode the host and return a URI with the scheme, authority, path, query, and fragment
    if (scheme != null && host != null) {
      final encodedHost = _punycodeCodec.encoder.convert(host);
      return Uri(
        scheme: scheme,
        userInfo: userInfo,
        host: encodedHost,
        port: port,
        path: path,
        query: query,
        fragment: fragment,
      ).normalizePath();
    }

    // If we have no scheme and an authority, we need to encode the host and return a URI with the authority, path, query, and fragment
    if (scheme == null && host != null) {
      final encodedHost = _punycodeCodec.encoder.convert(host);
      return Uri(
        userInfo: userInfo,
        host: encodedHost,
        port: port,
        path: path,
        query: query,
        fragment: fragment,
      ).normalizePath();
    }

    if (scheme == null && host == null) {
      // Handles relative-path and absolute-path references
      return Uri(
        path: path, // Already normalized
        query: query, // Already normalized
        fragment: fragment, // Already normalized
      ).normalizePath();
    }

    // If you reach here after the other checks we can throw an error
    // although the above condition should cover all remaining valid IRI-reference structures.
    throw StateError('Internal error: Unexpected IRI structure remaining.');
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

  // RFC 3986 Unreserved Characters: ALPHA / DIGIT / "-" / "." / "_" / "~"
  static const String _uriUnreservedChars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';

  // RFC 3986 Sub-delimiters: "!" / "$" / "&" / "'" / "(" / ")" / "*" / "+" / "," / ";" / "="
  static const String _uriSubDelimsChars = r"!$&'()*+,;=";

  // Characters generally allowed *without* percent-encoding within a URI path segment
  // pchar = unreserved / pct-encoded / sub-delims / ":" / "@"
  // We define the *non*-pct-encoded ones here for the check.
  // Note: We don't include '/' here because it's handled structurally.
  static const String _uriPathComponentAllowedChars =
      '$_uriUnreservedChars$_uriSubDelimsChars:@';

  // Characters generally allowed *without* percent-encoding within a URI query
  // query = *( pchar / "/" / "?" )
  static const String _uriQueryAllowedChars =
      '$_uriPathComponentAllowedChars/?';

  // Characters generally allowed *without* percent-encoding within a URI fragment
  // fragment = *( pchar / "/" / "?" )
  static const String _uriFragmentAllowedChars =
      '$_uriPathComponentAllowedChars/?';

  // Characters generally allowed *without* percent-encoding within URI userinfo
  // userinfo = *( unreserved / pct-encoded / sub-delims / ":" )
  static const String _uriUserInfoAllowedChars =
      '$_uriUnreservedChars$_uriSubDelimsChars:';

  // Main parsing and normalization method
  static Map<String, dynamic> _parseAndNormalize(String iri) {
    var remaining = iri;
    String? fragment;
    String? query;
    String? scheme;
    String? authority;
    String? userInfo;
    // Variables to store host details
    String? hostRaw;         // Host as extracted
    String? hostNormalized;  // Host after type-specific normalization
    _HostType? hostType;     // Enum for the type
    int? port;
    String path; // Will hold the parsed path before normalization

    // --- Steps 1, 2, 3 (Fragment, Query, Scheme extraction) remain the same ---
    // 1. Extract Fragment (Raw)
    final fragmentIndex = remaining.indexOf('#');
    if (fragmentIndex >= 0) {
      fragment = remaining.substring(fragmentIndex + 1);
      remaining = remaining.substring(0, fragmentIndex);
    }

    // 2. Extract Query (Raw)
    final queryIndex = remaining.indexOf('?');
    if (queryIndex >= 0) {
      query = remaining.substring(queryIndex + 1);
      remaining = remaining.substring(0, queryIndex);
    }

    // 3. Extract Scheme (Raw + Normalize Case)
    final schemeIndex = remaining.indexOf(':');
    final firstSlashIndex = remaining.indexOf('/');
    if (schemeIndex > 0 &&
        (firstSlashIndex == -1 || schemeIndex < firstSlashIndex)) {
      final potentialScheme = remaining.substring(0, schemeIndex);
      if (_IRIRegexHelper.matchScheme(potentialScheme)) {
        scheme = potentialScheme.toLowerCase(); // Case normalization
        remaining = remaining.substring(schemeIndex + 1);
      } else {
        throw FormatException(
          'Invalid scheme format: $potentialScheme in $iri',
        );
      }
    } else if (schemeIndex == 0) {
      throw FormatException('IRI cannot start with a colon: $iri');
    }


    // 4. Extract Authority (Raw) and Path (Raw)
    if (remaining.startsWith('//')) {
      remaining = remaining.substring(2);
      final authorityEndIndex = remaining.indexOf('/');
      if (authorityEndIndex >= 0) {
        authority = remaining.substring(0, authorityEndIndex);
        path = remaining.substring(authorityEndIndex); // Includes leading '/'
      } else {
        authority = remaining;
        path = ''; // Path is empty according to RFC3986 sec 3.3
      }

      // --- Start Refactored Authority Parsing ---
      if (authority.isNotEmpty) {
        final authRemaining = authority;
        final userInfoIndex = authRemaining.lastIndexOf('@');
        final hostStartIndex = userInfoIndex >= 0 ? userInfoIndex + 1 : 0;

        if (userInfoIndex >= 0) {
          userInfo = authRemaining.substring(0, userInfoIndex); // Raw user info
        }

        final hostAndPortString = authRemaining.substring(hostStartIndex);

        // --- Separate Host and Port ---
        String potentialHost;
        final ipv6EndBracketIndex = hostAndPortString.lastIndexOf(']');
        // Look for port separator *after* the closing bracket of an IPv6 literal
        final portSeparatorIndex = hostAndPortString.indexOf(':', (ipv6EndBracketIndex == -1) ? 0 : ipv6EndBracketIndex + 1);

        if (portSeparatorIndex != -1) {
          // Colon found after potential IPv6 literal
          final potentialPort = hostAndPortString.substring(portSeparatorIndex + 1);
          // Check if potentialPort is all digits and non-empty
          if (potentialPort.isNotEmpty && potentialPort.runes.every((r) => r >= 48 && r <= 57)) {
             port = int.tryParse(potentialPort); // Should succeed
             potentialHost = hostAndPortString.substring(0, portSeparatorIndex);
             if (port == null) {
                // This case should theoretically not happen if check above passes
                 throw FormatException('Invalid port format: $potentialPort in $iri');
             }
          } else if (potentialPort.isEmpty) {
            // Case like "host:", port is technically empty string, map to null/default
            port = null; // Or handle default port logic elsewhere
            potentialHost = hostAndPortString.substring(0, portSeparatorIndex);
          }
           else {
             // Colon present but not followed by digits (or empty) -> invalid port, treat colon as part of host
             port = null;
             potentialHost = hostAndPortString;
          }
        } else {
          // No port separator found after host
          potentialHost = hostAndPortString;
          port = null;
        }

        // RFC 3987 Sec 3.2.2: Empty host is not allowed if authority is present
        if (potentialHost.isEmpty) {
          throw FormatException('Host cannot be empty when authority is present: $iri');
        }

        // --- Determine Host Type and Normalize ---
        hostRaw = potentialHost; // Store raw host before normalization

        if (_IRIRegexHelper.isIpLiteral(potentialHost)) {
          hostType = _HostType.ipLiteral;
          // Normalize IPv6: Lowercase A-F hex digits within brackets.
          // Simple approach: find brackets, lowercase content between them.
          // Note: Doesn't handle full RFC 5952 canonicalization.
          final openBracket = potentialHost.indexOf('[');
          final closeBracket = potentialHost.lastIndexOf(']');
          if (openBracket != -1 && closeBracket > openBracket) {
             final ipContent = potentialHost.substring(openBracket + 1, closeBracket);
             // Also handle IPvFuture "v" - needs lowercase per RFC 3986 sec 3.2.2
             if (ipContent.startsWith('v') || ipContent.startsWith('V')){
                hostNormalized = '[${ipContent[0].toLowerCase()}${ipContent.substring(1).toLowerCase()}]';
             } else {
                hostNormalized = '[${ipContent.toLowerCase()}]';
             }
          } else {
            // Should not happen if isIpLiteral is true, but as fallback:
            hostNormalized = potentialHost.toLowerCase();
          }

        } else if (_IRIRegexHelper.isIPv4Address(potentialHost)) {
          hostType = _HostType.ipv4Address;
          hostNormalized = potentialHost; // No normalization needed for dotted quads

        } else if(_IRIRegexHelper.isRegisteredName(potentialHost)){
          hostType = _HostType.registeredName;
          hostNormalized = potentialHost.toLowerCase(); // Case normalization
        }

      } else {
        // Authority was empty "//", host cannot be empty.
        throw FormatException('Host cannot be empty when authority marker "//" is present: $iri');
      }
      // --- End Refactored Authority Parsing ---

    } else {
      // No authority, remaining is path
      path = remaining;
    }

    // 5. Normalize Other Components (Percent Encoding and Path Segments)
    if (userInfo != null) {
      userInfo = _normalizePercentEncoding(userInfo, _uriUserInfoAllowedChars);
    }

    // Normalize path (order matters: percent encoding first, then dot segments)
    path = _normalizePercentEncoding(path, _uriPathComponentAllowedChars);
    // Recommendation: Remove this and let Uri constructor handle dot segments
    // path = _removeDotSegments(path);

    if (query != null) {
      query = _normalizePercentEncoding(query, _uriQueryAllowedChars);
    }
    if (fragment != null) {
      fragment = _normalizePercentEncoding(fragment, _uriFragmentAllowedChars);
    }

    // Return map of *normalized* components including host details
    return {
      'scheme': scheme,
      'userInfo': userInfo,
      'hostRaw': hostRaw, // Raw extracted host
      'hostNormalized': hostNormalized, // Normalized host (case, etc.)
      'hostType': hostType, // Enum: ipLiteral, ipv4Address, registeredName
      'port': port,
      'path': path, // Path after percent normalization (dot segments handled later)
      'query': query,
      'fragment': fragment,
    };
  }

  /// Percent-encodes characters in an IRI component string to make it URI-compatible.
  ///
  /// It iterates through the input string and applies UTF-8 based percent-encoding
  /// to characters that are *not* in the `allowedChars` set and are *not* already
  /// part of a valid percent-encoding sequence (`%XX`).
  ///
  /// Args:
  ///   input: The IRI component string (e.g., path segment, query, fragment).
  ///   allowedChars: A string containing all characters allowed to appear *unencoded*
  ///                 in the corresponding *URI* component.
  ///
  /// Returns:
  ///   A string safe to use in a URI component.
  static String _normalizePercentEncoding(String input, String allowedChars) {
    final output = StringBuffer();
    // Create a Set for faster character lookup
    final allowedCharCodes = allowedChars.codeUnits.toSet();
    // We need to work with bytes for UTF-8 encoding and hex conversion
    final inputBytes = utf8.encode(input);

    for (var i = 0; i < inputBytes.length; i++) {
      final byte = inputBytes[i];

      // Check for existing percent encoding (%XX)
      // ASCII '%' is 37 (0x25)
      if (byte == 0x25) {
        // Check if there are enough characters left for a valid sequence
        if (i + 2 < inputBytes.length &&
            _isHexDigit(inputBytes[i + 1]) &&
            _isHexDigit(inputBytes[i + 2])) {
          // Valid %XX sequence found, append it directly
          output.write('%');
          output.writeCharCode(inputBytes[i + 1]);
          output.writeCharCode(inputBytes[i + 2]);
          i += 2; // Skip the two hex digits
          continue; // Move to the next byte
        }
        // If it's '%' but not followed by two hex digits, it's a literal '%'
        // that needs encoding itself according to RFC 3986.
        // Fall through to the encoding logic below.
      }

      // Check if the byte corresponds to a character in the allowed set
      // This works reliably only for single-byte characters (ASCII range)
      // For IRI processing, the assumption is that `allowedChars` contains only ASCII.
      // Non-ASCII chars from the IRI are *never* in `allowedChars` and will be encoded.
      if (byte < 128 && allowedCharCodes.contains(byte)) {
        // Allowed ASCII character, append directly
        output.writeCharCode(byte);
      } else {
        // Character is not allowed or is non-ASCII, percent-encode it
        output.write('%');
        output.write(byte.toRadixString(16).toUpperCase().padLeft(2, '0'));
      }
    }

    return output.toString();
  }

  /// Helper to check if a byte value represents an ASCII hex digit (0-9, A-F, a-f).
  static bool _isHexDigit(int byte) {
    return (byte >= 0x30 && byte <= 0x39) || // 0-9
        (byte >= 0x41 && byte <= 0x46) || // A-F
        (byte >= 0x61 && byte <= 0x66); // a-f
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

  static bool matchScheme(String input) =>
      RegExp('^$_scheme\$').hasMatch(input);

  static bool isIpLiteral(String input) =>
      RegExp('^$_ipLiteral\$').hasMatch(input);

  static bool isIPv4Address(String input) =>
      RegExp('^$_ipv4address\$').hasMatch(input);

  static bool isRegisteredName(String input) => RegExp('^$_iregName\$').hasMatch(input);
}

enum _HostType {
  ipLiteral,
  ipv4Address,
  registeredName,
}