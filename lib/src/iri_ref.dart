import 'package:meta/meta.dart';

import 'punycode/punycode_codec.dart';

/// Private helper class holding pre-compiled RegExps based on RFC 3987 grammar.
class _IriRegexUtils {
  _IriRegexUtils._(); // Private constructor to prevent instantiation

  // --- Core Character Sets ---
  static const String _schemePattern = r'[a-zA-Z][a-zA-Z0-9+\-.]*';
  static const String _ucscharPattern =
      r'[\u{a0}-\u{d7ff}\u{f900}-\u{fdcf}\u{fdf0}-\u{ffef}\u{10000}-\u{1fffd}\u{20000}-\u{2fffd}\u{30000}-\u{3fffd}\u{40000}-\u{4fffd}\u{50000}-\u{5fffd}\u{60000}-\u{6fffd}\u{70000}-\u{7fffd}\u{80000}-\u{8fffd}\u{90000}-\u{9fffd}\u{a0000}-\u{afffd}\u{b0000}-\u{bfffd}\u{c0000}-\u{cfffd}\u{d0000}-\u{dfffd}\u{e1000}-\u{efffd}]';
  static const String _iunreservedPattern = '([a-zA-Z0-9\\-._~]|$_ucscharPattern)';
  static const String _pctEncodedPattern = '%[0-9A-Fa-f]{2}'; // Ensure 2 hex digits
  static const String _subDelimsPattern = r"[!$&'()*+,;=]";
  static const String _iprivatePattern =
      r'[\u{e000}-\u{f8ff}\u{f0000}-\u{ffffd}\u{100000}-\u{10fffd}]';
  static const String _ipcharPattern =
      '($_iunreservedPattern|$_pctEncodedPattern|$_subDelimsPattern|[:@])';

  // --- Component Part Patterns ---
  static const String _iuserinfoPattern =
      '(?:$_iunreservedPattern|$_pctEncodedPattern|$_subDelimsPattern|:)*';
  static const String _h16 = '[0-9A-Fa-f]{1,4}';
  static const String _decOctet =
      '(?:[0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])';
  static const String _ipv4addressPattern =
      '$_decOctet\\.$_decOctet\\.$_decOctet\\.$_decOctet';
  static const String _ls32 = '(?:$_h16:$_h16|$_ipv4addressPattern)';
  // Note: Simplified IPv6 pattern for validation, full parsing is complex.
  // This aims to catch common valid forms but might not be exhaustive for all edge cases.
  // A dedicated IPv6 parser might be needed for full robustness.
  static const String _ipv6addressPattern = '(($_h16:){6}$_ls32|::($_h16:){5}$_ls32|($_h16)?::($_h16:){4}$_ls32|(($_h16:)?$_h16)?::($_h16:){3}$_ls32|(($_h16:){0,2}$_h16)?::($_h16:){2}$_ls32|(($_h16:){0,3}$_h16)?::$_h16:$_ls32|(($_h16:){0,4}$_h16)?::$_ls32|(($_h16:){0,5}$_h16)?::$_h16|(($_h16:){0,6}$_h16)?::)';
  static const String _ipvfuturePattern =
      '[vV][0-9A-Fa-f]+\\.($_iunreservedPattern|$_subDelimsPattern|:)+';
  static const String _ipLiteralPattern =
      '\\[(?:$_ipv6addressPattern|$_ipvfuturePattern)\\]';
  static const String _iregNamePattern =
      '(?:$_iunreservedPattern|$_pctEncodedPattern|$_subDelimsPattern)*';
  static const String _ihostPattern =
      '(?:$_ipLiteralPattern|$_ipv4addressPattern|$_iregNamePattern)';
  static const String _portPattern = '[0-9]*';
  static const String _iauthorityPattern = '(?:$_iuserinfoPattern@)?$_ihostPattern(?::$_portPattern)?';

  static const String _isegmentPattern = '(?:$_ipcharPattern)*';
  static const String _isegmentNzPattern = '(?:$_ipcharPattern)+'; // Non-zero length segment
  static const String _ipathAbemptyPattern = '(?:/$_isegmentPattern)*'; // Allows empty path or / followed by segments
  static const String _ipathAbsolutePattern = '/(?:$_isegmentNzPattern$_ipathAbemptyPattern)?'; // Must start with /, can be just '/'
  static const String _ipathNoschemePattern = '$_isegmentNzPattern$_ipathAbemptyPattern'; // Segment starting with non-colon char
  static const String _ipathRootlessPattern = '$_isegmentNzPattern$_ipathAbemptyPattern'; // Start with segment, no /
  static const String _ipathEmptyPattern = ''; // Completely empty path

  static const String _iqueryPattern =
      '(?:$_ipcharPattern|$_iprivatePattern|[/?])*';
  static const String _ifragmentPattern = '(?:$_ipcharPattern|[/?])*';

  // --- Full IRI Patterns (mainly for initial validation) ---
  static const String _ihierPartPattern =
      '(?:(?://$_iauthorityPattern$_ipathAbemptyPattern)|$_ipathAbsolutePattern|$_ipathRootlessPattern|$_ipathEmptyPattern)';
  static const String _iriPattern =
      '$_schemePattern:$_ihierPartPattern(?:\\?$_iqueryPattern)?(?:#$_ifragmentPattern)?';

  static const String _irelativePartPattern =
      '(?:(?://$_iauthorityPattern$_ipathAbemptyPattern)|$_ipathAbsolutePattern|$_ipathNoschemePattern|$_ipathEmptyPattern)';
  static const String _irelativeRefPattern =
      '$_irelativePartPattern(?:\\?$_iqueryPattern)?(?:#$_ifragmentPattern)?';

  // The full pattern to validate an IRI reference (absolute IRI or relative reference)
  static const String _iriReferencePattern = '(?:$_iriPattern|$_irelativeRefPattern)';

  // --- Pre-compiled RegExp Objects ---

  /// Regex to validate the scheme component.
  static final RegExp scheme = RegExp('^$_schemePattern\$');

  /// Regex to validate allowed characters in the userinfo component.
  static final RegExp iuserInfoChars =
      RegExp('^($_iunreservedPattern|$_pctEncodedPattern|$_subDelimsPattern|:)*\$', unicode: true);

  /// Regex to validate an IPv4 address literal.
  static final RegExp ipv4Address = RegExp('^$_ipv4addressPattern\$');

  /// Regex to validate an IP literal (IPv6 or IPvFuture).
  static final RegExp ipLiteral = RegExp('^$_ipLiteralPattern\$');

   /// Regex to validate a registered name host component.
  static final RegExp iregName = RegExp('^$_iregNamePattern\$', unicode: true);

  /// Regex to validate the host component (IP literal, IPv4, or reg name).
  static final RegExp ihost = RegExp('^$_ihostPattern\$', unicode: true);

  /// Regex to validate allowed characters in the path component.
  /// Note: Path structure (e.g., starting `/`) is handled by parsing logic,
  /// this checks the characters *within* segments.
  static final RegExp iPathChars = RegExp('^$_ipcharPattern*\$', unicode: true);

  /// Regex to validate allowed characters in the query component.
  static final RegExp iQueryChars = RegExp('^$_iqueryPattern\$', unicode: true);

  /// Regex to validate allowed characters in the fragment component.
  static final RegExp iFragmentChars = RegExp('^$_ifragmentPattern\$', unicode: true);

  /// Regex for a quick initial check if the *entire* string conforms to
  /// the IRI-reference grammar (absolute or relative).
  /// Use this for early exit before detailed parsing.
  static final RegExp iriReference =
      RegExp('^$_iriReferencePattern\$', unicode: true);

   /// Regex to find percent-encoded triplets.
  static final RegExp pctEncoded = RegExp(_pctEncodedPattern);

  /// Regex to find dot-segments (`.` or `..`) in a path.
  static final RegExp dotSegments = RegExp(r'(?:^|/)\.(?:/|$)'); // Matches /./ or /^./
  static final RegExp doubleDotSegments = RegExp(r'(?:^|/)\.\.(?:/|$)'); // Matches /../ or /^../
  static final RegExp leadingSlashDot = RegExp(r'^/\.');
  static final RegExp leadingSlashDoubleDot = RegExp(r'^/\.\.');
}


/// Represents an Internationalized Resource Identifier (IRI) according to RFC 3987.
///
/// This class focuses on the parsing, validation, component access, normalization,
/// and URI conversion of IRIs. It is intended as a foundational IRI type,
/// distinct from its role as an RDF term.
@immutable
class IriRef {

  /// The original, un-normalized IRI string provided to the constructor.
  final String originalValue;

  // Parsed and normalized components
  late final String? _scheme;
  late final String? _userInfo;
  late final String? _host;
  late final int? _port;
  late final String _path; // Path is mandatory, though can be empty
  late final String? _query;
  late final String? _fragment;

  /// Parses an IRI string according to RFC 3987 rules.
  ///
  /// Performs syntax-based normalization (case, percent-encoding, path segments)
  /// during parsing. Throws [FormatException] if the input string is not a valid IRI.
  ///
  /// Unicode normalization (NFC/NFD) is NOT performed by default.
  IriRef(String iri) : originalValue = iri {
    // Optional: Quick pre-validation - might save work if clearly invalid
    if (!_IriRegexUtils.iriReference.hasMatch(iri)) {
      throw FormatException('Invalid IRI reference syntax: $iri');
    }

    try {
      final components = _parseAndNormalize(iri);
      _scheme = components['scheme'] as String?;
      _userInfo = components['userInfo'] as String?;
      _host = components['host'] as String?;
      _port = components['port'] as int?;
      _path = components['path'] as String;
      _query = components['query'] as String?;
      _fragment = components['fragment'] as String?;

      // Post-parsing validation of individual components (using regex utils)
      if (_scheme != null && !_IriRegexUtils.scheme.hasMatch(_scheme!)) {
        throw FormatException('Invalid scheme component: $_scheme');
      }
      if (_userInfo != null && !_IriRegexUtils.iuserInfoChars.hasMatch(_userInfo!)) {
         throw FormatException('Invalid characters in userinfo component: $_userInfo');
      }
      // Host validation is complex: check IPv4, IP Literal, then RegName
      if (_host != null &&
          !_IriRegexUtils.ipLiteral.hasMatch(_host!) &&
          !_IriRegexUtils.ipv4Address.hasMatch(_host!) &&
          !_IriRegexUtils.iregName.hasMatch(_host!) ) {
           throw FormatException('Invalid host component: $_host');
      }
       if (_query != null && !_IriRegexUtils.iQueryChars.hasMatch(_query!)) {
         throw FormatException('Invalid characters in query component: $_query');
      }
       if (_fragment != null && !_IriRegexUtils.iFragmentChars.hasMatch(_fragment!)) {
         throw FormatException('Invalid characters in fragment component: $_fragment');
      }
      // Note: Path character validation (_IriRegexUtils.iPathChars) should ideally happen
      // segment by segment *during* path normalization/parsing. A simple check
      // on the final path might be too broad if normalization modified it heavily.

    } on FormatException {
      rethrow;
    } catch (e, s) {
      throw FormatException('Failed to parse IRI ($e): $iri', s);
    }
  }

  // Placeholder for the complex parsing/normalization logic
  // This now uses the helper class for validation checks.
  static Map<String, dynamic> _parseAndNormalize(String iri) {
    var remaining = iri;
    String? fragment;
    String? query;
    String? scheme;
    String? authority;
    String? userInfo;
    String? host;
    int? port;
    String path;

    // 1. Extract Fragment
    final fragmentIndex = remaining.indexOf('#');
    if (fragmentIndex >= 0) {
      fragment = remaining.substring(fragmentIndex + 1);
      remaining = remaining.substring(0, fragmentIndex);
      // TODO: Normalize percent encoding in fragment
    }

    // 2. Extract Query
    final queryIndex = remaining.indexOf('?');
    if (queryIndex >= 0) {
      query = remaining.substring(queryIndex + 1);
      remaining = remaining.substring(0, queryIndex);
      // TODO: Normalize percent encoding in query
    }

    // 3. Extract Scheme
    final schemeIndex = remaining.indexOf(':');
    // Need to ensure ':' isn't part of the first path segment in a relative IRI
    final firstSlashIndex = remaining.indexOf('/');
    if (schemeIndex > 0 && (firstSlashIndex == -1 || schemeIndex < firstSlashIndex)) {
        final potentialScheme = remaining.substring(0, schemeIndex);
        if (_IriRegexUtils.scheme.hasMatch(potentialScheme)) { // Use helper regex
            scheme = potentialScheme.toLowerCase(); // Case normalization
            remaining = remaining.substring(schemeIndex + 1);
        } else {
            throw FormatException('Invalid scheme format: $potentialScheme in $iri');
        }
    } else if (schemeIndex == 0) {
        throw FormatException('IRI cannot start with a colon: $iri');
    }
    // If schemeIndex < 0 or after first '/', no scheme is present.


    // 4. Extract Authority and Path
    if (remaining.startsWith('//')) {
        remaining = remaining.substring(2);
        final authorityEndIndex = remaining.indexOf('/');
        if (authorityEndIndex >= 0) {
            authority = remaining.substring(0, authorityEndIndex);
            path = remaining.substring(authorityEndIndex); // Path starts with '/'
        } else {
            authority = remaining;
            path = ''; // Path is empty according to RFC3986 sec 3.3
        }

        // 4a. Parse Authority
        if (authority.isNotEmpty) {
            final authRemaining = authority;
            // UserInfo
            final userInfoIndex = authRemaining.lastIndexOf('@');
            final hostStartIndex = userInfoIndex >= 0 ? userInfoIndex + 1 : 0;

            // Port / Host split - Handle IPv6 literal case carefully
            final portSeparatorIndex = authRemaining.indexOf(':', hostStartIndex);
            final ipv6EndIndex = authRemaining.lastIndexOf(']');

            if (userInfoIndex >= 0) {
                userInfo = authRemaining.substring(0, userInfoIndex);
                 // Validation moved to constructor body
                 // TODO: Normalize percent encoding in userInfo
            }

            final hostAndPort = authRemaining.substring(hostStartIndex);
            String potentialHost;

            // Check if ':' is present AND *outside* an IPv6 literal '[]'
            if (portSeparatorIndex > ipv6EndIndex) {
                final potentialPort = hostAndPort.substring(portSeparatorIndex + 1);
                if (potentialPort.isNotEmpty && potentialPort.runes.every((r) => r >= 48 && r <= 57)) {
                    port = int.tryParse(potentialPort);
                    if (port != null) {
                        potentialHost = hostAndPort.substring(0, portSeparatorIndex);
                    } else {
                         // Invalid port format, treat ':' as part of host (will likely fail validation later)
                        potentialHost = hostAndPort;
                        port = null; // Reset port
                    }
                } else {
                     // ':' present but not followed by digits -> part of host (e.g. IPv6)
                    potentialHost = hostAndPort;
                }
            } else { // No ':' or ':' is inside IPv6 literal
                potentialHost = hostAndPort;
            }
            // Host validation moved to constructor body
            host = potentialHost.toLowerCase(); // Case normalization for host (including Punycode ACE form if present)

        } else {
          // Authority was empty "//" which is invalid per RFC 3987 Sec 3.2 (ihost must not be empty)
          // Although RFC 3986 allows empty authority in some contexts, IRI seems stricter? Recheck spec.
          // For now, let host validation catch this (empty host string fails).
        }

    } else { // No authority, remaining is path
        path = remaining;
    }

    // 5. Normalize Path
    // TODO: Implement path segment normalization (remove ., ..) - CRITICAL
    // TODO: Normalize percent encoding in path - CRITICAL


    // Return map of *potentially* normalized components (pending TODOs)
    return {
        'scheme': scheme,
        'userInfo': userInfo, // Should be normalized
        'host': host, // Normalized case
        'port': port,
        'path': path, // Should be normalized path & percent encoding
        'query': query, // Should be normalized percent encoding
        'fragment': fragment, // Should be normalized percent encoding
    };
  }


  // --- Component Accessors ---
  // (Keep existing accessors, they retrieve the final fields)
  String? get scheme => _scheme;
  String? get authority {
    if (_host == null && _userInfo == null && _port == null) return null; // Only return null if all parts are null
    var result = '';
    if (_userInfo != null) result += '$_userInfo@';
    // RFC 3986: Authority requires host. If host is null/empty but user/port exist,
    // it's technically invalid, though parsing might have allowed it.
    // Let's assume _host is non-empty if authority is non-null.
    result += _host ?? ''; // Should ideally not be null if authority present
    if (_port != null) result += ':$_port';
    return result.isEmpty ? null : result; // Return null if somehow all components resulted in empty string
  }
  String? get userInfo => _userInfo;
  String? get host => _host;
  int? get port => _port;
  String get path => _path; // Path is never null
  String? get query => _query;
  String? get fragment => _fragment;

  // --- Core Methods (Stubs) ---

  String toUriString() {
    // TODO: Implement IRI-to-URI conversion algorithm
    return originalValue; // Placeholder
  }

  IriRef resolve(String relativeReference) {
    // TODO: Implement relative IRI resolution
    return IriRef(originalValue + relativeReference); // Placeholder
  }

  IriRef resolveUri(IriRef reference) {
    return resolve(reference.toString()); // Delegate
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! IriRef) return false;
    // TODO: Compare the *normalized* components for equality.
    return _scheme == other._scheme &&
           _userInfo == other._userInfo &&
           _host == other._host &&
           _port == other._port &&
           _path == other._path && // Requires path normalization to be correct
           _query == other._query &&
           _fragment == other._fragment;
  }

  @override
  int get hashCode {
    // TODO: Compute hash code based on the *normalized* components.
    return Object.hash(
      _scheme,
      _userInfo,
      _host,
      _port,
      _path, // Requires path normalization to be correct
      _query,
      _fragment,
    );
  }

  @override
  String toString() {
    // Consider reconstructing from normalized components for canonical string?
    // Or stick to original value? Sticking to originalValue for now.
    return originalValue;
  }
}
