import 'dart:convert';

import 'package:meta/meta.dart';

import 'package:rdf_dart/src/punycode/punycode_codec.dart';

/// Private helper class holding pre-compiled RegExps based on RFC 3987 grammar.
class _IriRegexUtils {
  _IriRegexUtils._(); // Private constructor to prevent instantiation

  // --- Core Character Sets ---
  static const String _schemePattern = r'[a-zA-Z][a-zA-Z0-9+\-.]*';
  static const String _ucscharPattern =
      r'[\u{a0}-\u{d7ff}\u{f900}-\u{fdcf}\u{fdf0}-\u{ffef}\u{10000}-\u{1fffd}\u{20000}-\u{2fffd}\u{30000}-\u{3fffd}\u{40000}-\u{4fffd}\u{50000}-\u{5fffd}\u{60000}-\u{6fffd}\u{70000}-\u{7fffd}\u{80000}-\u{8fffd}\u{90000}-\u{9fffd}\u{a0000}-\u{afffd}\u{b0000}-\u{bfffd}\u{c0000}-\u{cfffd}\u{d0000}-\u{dfffd}\u{e1000}-\u{efffd}]';
  static const String _iunreservedPattern =
      '([a-zA-Z0-9-._~]|$_ucscharPattern)';
  static const String _pctEncodedPattern =
      '%[0-9A-Fa-f]{2}'; // Ensure 2 hex digits
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
      '$_decOctet.$_decOctet.$_decOctet.$_decOctet';
  static const String _ls32 = '(?:$_h16:$_h16|$_ipv4addressPattern)';
  // Note: Using the more robust IPv6 pattern from the original source
  static const String _ipv6addressPattern =
      '(($_h16:){6}$_ls32|::($_h16:){5}$_ls32|($_h16)?::($_h16:){4}$_ls32|(($_h16:)?$_h16)?::($_h16:){3}$_ls32|(($_h16:){0,2}$_h16)?::($_h16:){2}$_ls32|(($_h16:){0,3}$_h16)?::$_h16:$_ls32|(($_h16:){0,4}$_h16)?::$_ls32|(($_h16:){0,5}$_h16)?::$_h16|(($_h16:){0,6}$_h16)?::)';
  static const String _ipvfuturePattern =
      '[vV][0-9A-Fa-f]+.($_iunreservedPattern|$_subDelimsPattern|:)+';
  static const String _ipLiteralPattern =
      '[(?:$_ipv6addressPattern|$_ipvfuturePattern)]';
  static const String _iregNamePattern =
      '(?:$_iunreservedPattern|$_pctEncodedPattern|$_subDelimsPattern)*';
  static const String _ihostPattern =
      '(?:$_ipLiteralPattern|$_ipv4addressPattern|$_iregNamePattern)';
  static const String _portPattern = '[0-9]*';
  static const String _iauthorityPattern =
      '(?:$_iuserinfoPattern@)?$_ihostPattern(?::$_portPattern)?';

  static const String _isegmentPattern = '(?:$_ipcharPattern)*';
  static const String _isegmentNzPattern =
      '(?:$_ipcharPattern)+'; // Non-zero length segment
  static const String _ipathAbemptyPattern =
      '(?:/$_isegmentPattern)*'; // Allows empty path or / followed by segments
  static const String _ipathAbsolutePattern =
      '/(?:$_isegmentNzPattern$_ipathAbemptyPattern)?'; // Must start with /, can be just '/'
  static const String _ipathNoschemePattern =
      '$_isegmentNzPattern$_ipathAbemptyPattern'; // Segment starting with non-colon char
  static const String _ipathRootlessPattern =
      '$_isegmentNzPattern$_ipathAbemptyPattern'; // Start with segment, no /
  static const String _ipathEmptyPattern = ''; // Completely empty path

  static const String _iqueryPattern =
      '(?:$_ipcharPattern|$_iprivatePattern|[/?])*';
  static const String _ifragmentPattern = '(?:$_ipcharPattern|[/?])*';

  // --- Full IRI Patterns (mainly for initial validation) ---
  static const String _ihierPartPattern =
      '(?:(?://$_iauthorityPattern$_ipathAbemptyPattern)|$_ipathAbsolutePattern|$_ipathRootlessPattern|$_ipathEmptyPattern)';
  static const String _iriPattern =
      '$_schemePattern:$_ihierPartPattern(?:?$_iqueryPattern)?(?:#$_ifragmentPattern)?';

  static const String _irelativePartPattern =
      '(?:(?://$_iauthorityPattern$_ipathAbemptyPattern)|$_ipathAbsolutePattern|$_ipathNoschemePattern|$_ipathEmptyPattern)';
  static const String _irelativeRefPattern =
      '$_irelativePartPattern(?:?$_iqueryPattern)?(?:#$_ifragmentPattern)?';

  // The full pattern to validate an IRI reference (absolute IRI or relative reference)
  static const String _iriReferencePattern =
      '(?:$_iriPattern|$_irelativeRefPattern)';

  // --- Pre-compiled RegExp Objects ---

  /// Regex to validate the scheme component.
  static final RegExp scheme = RegExp('^$_schemePattern\$');

  /// Regex to validate allowed characters in the userinfo component.
  static final RegExp iuserInfoChars = RegExp(
    '^($_iunreservedPattern|$_pctEncodedPattern|$_subDelimsPattern|:)*\$',
    unicode: true,
  );

  /// Regex to validate an IPv4 address literal.
  static final RegExp ipv4Address = RegExp('^$_ipv4addressPattern\$');

  /// Regex to validate an IP literal (IPv6 or IPvFuture).
  static final RegExp ipLiteral = RegExp(
    '^$_ipLiteralPattern\$',
    unicode: true,
  ); // Added unicode flag

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
  static final RegExp iFragmentChars = RegExp(
    '^$_ifragmentPattern\$',
    unicode: true,
  );

  /// Regex for a quick initial check if the *entire* string conforms to
  /// the IRI-reference grammar (absolute or relative).
  /// Use this for early exit before detailed parsing.
  static final RegExp iriReference = RegExp(
    '^$_iriReferencePattern\$',
    unicode: true,
  );

  /// Regex to find percent-encoded triplets.
  static final RegExp pctEncoded = RegExp(_pctEncodedPattern);

  // Note: Regexes for dot segments were removed as the logic is handled in _removeDotSegments directly.
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

  // Define allowed character sets for URI components (based on RFC 3986)
  // Note: These are *stricter* than the IRI character sets.
  static const String _uriUnreserved =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
  static const String _uriSubDelims = r"!$&'()*+,;=";
  // Allowed characters vary by component:
  static const String _uriUserInfoAllowed = '$_uriUnreserved$_uriSubDelims:';
  // Path allows pchar = unreserved / pct-encoded / sub-delims / : / @
  // We only need to list the *unescaped* ASCII chars allowed here.
  // '/' is also allowed structurally but handled by joining segments.
  static const String _uriPathAllowed =
      '$_uriUnreserved$_uriSubDelims:@/'; // '/' added for convenience
  // Query and Fragment allow pchar + /?
  static const String _uriQueryAllowed = '$_uriUnreserved$_uriSubDelims:@/?';
  static const String _uriFragmentAllowed = '$_uriUnreserved$_uriSubDelims:@/?';

  /// Parses an IRI string according to RFC 3987 rules.
  ///
  /// Performs syntax-based normalization (case, percent-encoding, path segments)
  /// during parsing. Throws [FormatException] if the input string is not a valid IRI.
  ///
  /// Unicode normalization (NFC/NFD) is NOT performed by default.
  IriRef(String iri) : originalValue = iri {

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
      // These checks happen *after* normalization.
      if (_scheme != null && !_IriRegexUtils.scheme.hasMatch(_scheme)) {
        // This should theoretically not happen if parsing logic is correct
        throw FormatException('Invalid scheme component after parse: $_scheme');
      }
      if (_userInfo != null &&
          !_IriRegexUtils.iuserInfoChars.hasMatch(_userInfo)) {
        // Should not happen if percent normalization and parsing were correct
        throw FormatException(
          'Invalid characters in normalized userinfo component: $_userInfo',
        );
      }
      // Host validation is complex: check IPv4, IP Literal, then RegName
      if (_host != null &&
          _host
              .isNotEmpty && // Empty host is allowed if authority is absent, but not if // present
          !_IriRegexUtils.ipLiteral.hasMatch(_host) &&
          !_IriRegexUtils.ipv4Address.hasMatch(_host) &&
          !_IriRegexUtils.iregName.hasMatch(_host)) {
        throw FormatException(
          'Invalid host component after parse/normalize: $_host',
        );
      }
      if (_query != null && !_IriRegexUtils.iQueryChars.hasMatch(_query)) {
        // Should not happen if percent normalization and parsing were correct
        throw FormatException(
          'Invalid characters in normalized query component: $_query',
        );
      }
      if (_fragment != null &&
          !_IriRegexUtils.iFragmentChars.hasMatch(_fragment)) {
        // Should not happen if percent normalization and parsing were correct
        throw FormatException(
          'Invalid characters in normalized fragment component: $_fragment',
        );
      }
      // Note: Path character validation is implicitly handled by percent normalization
      // and the fact that parsing splits based on valid delimiters.
    } on FormatException {
      rethrow;
    } catch (e, s) {
      throw FormatException('Failed to parse IRI ($e): $iri', s);
    }
  }

  // Helper to get hex value of a code unit (char code)
  static int _hexValue(int codeUnit) {
    if (codeUnit >= 0x30 /* 0 */ && codeUnit <= 0x39 /* 9 */ ) {
      return codeUnit - 0x30;
    }
    if (codeUnit >= 0x41 /* A */ && codeUnit <= 0x46 /* F */ ) {
      return codeUnit - 0x41 + 10;
    }
    if (codeUnit >= 0x61 /* a */ && codeUnit <= 0x66 /* f */ ) {
      return codeUnit - 0x61 + 10;
    }
    return -1; // Not a hex digit
  }

  /// Normalizes percent-encoded sequences in a string component according to RFC 3987.
  /// - Decodes unreserved characters (%41 -> A).
  /// - Uppercases hexadecimal digits in valid percent-encodings (%3a -> %3A).
  /// - Assumes input is UTF-8 encoded where percent-encoding represents bytes.
  static String _normalizePercentEncoding(String component) {
    // Define unreserved characters based on RFC 3986 Section 2.3
    const unreservedChars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';

    final result = StringBuffer();
    final codeUnits = component.codeUnits;
    var i = 0;
    while (i < codeUnits.length) {
      final unit = codeUnits[i];
      if (unit == 0x25 /* % */ && i + 2 < codeUnits.length) {
        final hex1 = codeUnits[i + 1];
        final hex2 = codeUnits[i + 2];
        final digit1 = _hexValue(hex1);
        final digit2 = _hexValue(hex2);

        if (digit1 != -1 && digit2 != -1) {
          // Valid percent-encoding found
          final byteValue = (digit1 << 4) + digit2;
          // Decode ONLY if the decoded byte corresponds to an ASCII unreserved character.
          if (byteValue < 128) {
            final char = String.fromCharCode(byteValue);
            if (unreservedChars.contains(char)) {
              result.write(char); // Decode unreserved
            } else {
              // Reserved ASCII or invalid byte, keep encoded, normalize case
              result.write(
                '%${String.fromCharCode(hex1).toUpperCase()}${String.fromCharCode(hex2).toUpperCase()}',
              );
            }
          } else {
            // Non-ASCII byte, keep encoded, normalize case
            result.write(
              '%${String.fromCharCode(hex1).toUpperCase()}${String.fromCharCode(hex2).toUpperCase()}',
            );
          }
          i += 3; // Move past %XX
        } else {
          // Invalid percent-encoding (e.g., "%G0"), treat '%' literally
          result.write('%');
          i++;
        }
      } else {
        // Not a percent sign or not enough characters for encoding, write unit as is
        result.writeCharCode(unit);
        i++;
      }
    }
    return result.toString();
  }

  /// Removes dot-segments ("." and "..") from a path component according to RFC 3986, Section 5.2.4.
  /// Assumes the input path has already had percent-encoding normalized if necessary.
  static String _removeDotSegments(String path) {
    // Based on algorithm from RFC 3986, Section 5.2.4 Step 2
    if (path.isEmpty) return '';

    final output = <String>[]; // Use a List<String> for segments
    var input = path; // Work with the path as a String

    while (input.isNotEmpty) {
      // Step 2.A: Check for "../" or "./" at the beginning
      if (input.startsWith('../')) {
        input = input.substring(3); // Remove "../"
      } else if (input.startsWith('./')) {
        input = input.substring(2); // Remove "./"
        // Step 2.B: Check for "/./" or "/." at the end
      } else if (input.startsWith('/./')) {
        input = '/${input.substring(3)}'; // Replace "/./" with "/"
      } else if (input == '/.') {
        input = '/'; // Replace "/." with "/"
        // Step 2.C: Check for "/../" or "/.." at the end
      } else if (input.startsWith('/../')) {
        input = '/${input.substring(4)}'; // Replace "/../" with "/"
        if (output.isNotEmpty) {
          output.removeLast(); // Remove last segment from output
        }
      } else if (input == '/..') {
        input = '/'; // Replace "/.." with "/"
        if (output.isNotEmpty) {
          output.removeLast(); // Remove last segment from output
        }
        // Step 2.D: Check for "." or ".." segments
      } else if (input == '.' || input == '..') {
        input = ''; // Remove the segment
        // Step 2.E: Move the first path segment from input to output
      } else {
        // Find the first '/' character
        var segmentEnd = input.indexOf('/');
        if (segmentEnd == 0) {
          // Starts with '/' (e.g., "/abc")
          segmentEnd = input.indexOf('/', 1); // Find the *next* '/'
        }

        String segment;
        if (segmentEnd == -1) {
          // No more '/' found
          segment = input;
          input = '';
        } else {
          segment = input.substring(0, segmentEnd);
          input = input.substring(
            segmentEnd,
          ); // Keep the leading '/' for the next iteration
        }
        output.add(segment);
      }
    }

    // Step 3: Reconstruct the path
    return output.join(); // Join the processed segments
  }

  // Main parsing and normalization method
  static Map<String, dynamic> _parseAndNormalize(String iri) {
    var remaining = iri;
    String? fragment;
    String? query;
    String? scheme;
    String? authority;
    String? userInfo;
    String? host;
    int? port;
    String path; // Will hold the parsed path before normalization

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
      if (_IriRegexUtils.scheme.hasMatch(potentialScheme)) {
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

      // 4a. Parse Authority (Raw + Normalize Host Case)
      if (authority.isNotEmpty) {
        final authRemaining = authority;
        final userInfoIndex = authRemaining.lastIndexOf('@');
        final hostStartIndex = userInfoIndex >= 0 ? userInfoIndex + 1 : 0;
        final portSeparatorIndex = authRemaining.indexOf(':', hostStartIndex);
        final ipv6EndIndex = authRemaining.lastIndexOf(']');

        if (userInfoIndex >= 0) {
          userInfo = authRemaining.substring(0, userInfoIndex); // Raw user info
        }

        final hostAndPort = authRemaining.substring(hostStartIndex);
        String potentialHost;

        if (portSeparatorIndex > ipv6EndIndex) {
          final potentialPort = hostAndPort.substring(portSeparatorIndex + 1);
          if (potentialPort.runes.every((r) => r >= 48 && r <= 57)) {
            // Check if numeric
            if (potentialPort.isNotEmpty) {
              // Allow empty only if no ':'
              port = int.tryParse(potentialPort);
            }
            if (port != null) {
              potentialHost = hostAndPort.substring(0, portSeparatorIndex);
            } else {
              // Invalid port format, treat ':' as part of host
              potentialHost = hostAndPort;
              port = null;
            }
          } else {
            // ':' present but not followed by digits -> part of host
            potentialHost = hostAndPort;
          }
        } else {
          // No ':' or ':' is inside IPv6 literal
          potentialHost = hostAndPort;
        }
        // Host validation happens later in constructor
        host = potentialHost.toLowerCase(); // Case normalization for host
        // RFC 3987 Sec 3.2.2: Empty host is not allowed if authority is present
        if (host.isEmpty) {
          throw FormatException(
            'Host cannot be empty when authority is present: $iri',
          );
        }
      } else {
        // Authority was empty "//", host cannot be empty.
        throw FormatException(
          'Host cannot be empty when authority marker "//" is present: $iri',
        );
      }
    } else {
      // No authority, remaining is path
      path = remaining;
    }

    // 5. Normalize Components (Percent Encoding and Path Segments)
    if (userInfo != null) {
      userInfo = _normalizePercentEncoding(userInfo);
    }
    // Normalize path (order matters)
    path = _normalizePercentEncoding(path);
    path = _removeDotSegments(path);

    if (query != null) {
      query = _normalizePercentEncoding(query);
    }
    if (fragment != null) {
      fragment = _normalizePercentEncoding(fragment);
    }

    // Return map of *normalized* components
    return {
      'scheme': scheme,
      'userInfo': userInfo,
      'host': host,
      'port': port,
      'path': path,
      'query': query,
      'fragment': fragment,
    };
  }

  // --- Component Accessors ---
  String? get scheme => _scheme;
  String? get authority {
    // Reconstruct from normalized parts
    if (_host == null || _host.isEmpty) {
      return null; // Authority requires a host
    }
    final result = StringBuffer();
    if (_userInfo != null) {
      result.write(_userInfo);
      result.write('@');
    }
    result.write(_host);
    if (_port != null) {
      result.write(':');
      result.write(_port);
    }
    return result.toString();
  }

  String? get userInfo => _userInfo;
  String? get host => _host;
  int? get port => _port;
  String get path => _path; // Path is never null (can be empty string)
  String? get query => _query;
  String? get fragment => _fragment;

  // --- Core Methods (Stubs / TODO ) ---

  /// Converts this IRI to its corresponding URI representation as a String,
  /// as defined by RFC 3987, Section 3.1.
  ///
  /// This involves percent-encoding non-ASCII characters in relevant components
  /// and converting the host to Punycode if necessary.
  String toUriString() {
    final sb = StringBuffer();
    if (_scheme != null) {
      sb.write(_scheme);
      sb.write(':');
    }

    var uriHost = _host;
    // Apply Punycode to host if it contains non-ASCII chars
    if (uriHost != null &&
        uriHost.isNotEmpty &&
        uriHost.runes.any((r) => r > 127)) {
      try {
        uriHost = PunycodeCodec().encode(uriHost);
      } catch (e) {
        // RFC 3987 doesn't specify error handling here. Options:
        // 1. Throw: Strict compliance, but might break applications.
        // 2. Use original: Might lead to invalid URIs if host was required.
        // 3. Return empty/null: Might break applications expecting a URI.
        // Let's rethrow for now, as a failed Punycode conversion indicates
        // a problem with the input IRI's host that should be addressed.
        throw FormatException(
          "Punycode encoding failed for host '$_host': $e",
          e,
        );
      }
    }

    // Rebuild authority if host is present
    if (uriHost != null && uriHost.isNotEmpty) {
      sb.write('//');
      if (_userInfo != null) {
        sb.write(
          _percentEncodeUriComponentChars(_userInfo, _uriUserInfoAllowed),
        );
        sb.write('@');
      }
      sb.write(uriHost); // Already ASCII (Punycode or original) and lowercase
      if (_port != null) {
        sb.write(':');
        sb.write(_port);
      }
    }

    // Path: Must handle encoding carefully, respecting '/' delimiters.
    // Encode each segment individually, then join.
    if (_path.isNotEmpty) {
      // Our normalized _path might not have a leading slash if rootless,
      // but URI requires path to start with / if authority present.
      // Also handle path starting with ':' if no scheme/authority (e.g. "foo:bar")
      if (uriHost != null && uriHost.isNotEmpty && !_path.startsWith('/')) {
        // Add leading slash if authority is present but path isn't absolute
        sb.write('/');
      }

      final segments = _path.split('/');
      final encodedSegments =
          segments
              .map(
                (segment) => _percentEncodeUriComponentChars(
                  segment,
                  '$_uriUnreserved$_uriSubDelims:@',
                ),
              ) // Allowed pchars (excluding '/')
              .toList();

      // Re-join, preserving original structure (leading/trailing slashes)
      if (_path.startsWith('/')) {
        // Handle cases like "/" -> ["", ""] -> join -> "" - needs fix
        if (encodedSegments.length > 1 && encodedSegments.first.isEmpty) {
          sb.write('/'); // Ensure leading slash from original is kept
          sb.write(encodedSegments.sublist(1).join('/'));
        } else if (encodedSegments.length == 1 &&
            encodedSegments.first.isEmpty) {
          sb.write('/'); // Path was just "/"
        } else {
          // Path was like "/a/b" -> ["", "a", "b"] -> join needed adjustment
          // This case might be handled by the sublist(1) above. Let's test.
          sb.write('/');
          sb.write(encodedSegments.sublist(1).join('/'));
        }
      } else {
        // Path was like "a/b" -> ["a", "b"]
        sb.write(encodedSegments.join('/'));
      }
      // Preserve trailing slash if present originally (and not just '/')
      if (_path.length > 1 && _path.endsWith('/')) {
        sb.write('/');
      }
    } else if (uriHost != null && uriHost.isNotEmpty) {
      // If authority is present, path must start with '/' even if empty originally
      sb.write('/');
    }

    if (_query != null) {
      sb.write('?');
      sb.write(_percentEncodeUriComponentChars(_query, _uriQueryAllowed));
    }
    if (_fragment != null) {
      sb.write('#');
      sb.write(
        _percentEncodeUriComponentChars(_fragment, _uriFragmentAllowed),
      );
    }
    return sb.toString();
  }

  /// Percent-encodes characters in a component for URI conversion (RFC 3987 Sec 3.1).
  ///
  /// Encodes non-ASCII characters based on UTF-8 bytes and disallowed ASCII characters.
  /// The specific set of allowed ASCII characters depends on the component type.
  static String _percentEncodeUriComponentChars(
    String component,
    String allowedAsciiChars,
  ) {
    final bytes = utf8.encode(
      component,
    ); // Encode the whole component to UTF-8 bytes
    final result = StringBuffer();

    for (final byte in bytes) {
      // Check if the byte corresponds to an allowed ASCII character for this component
      if (byte < 128) {
        final char = String.fromCharCode(byte);
        if (allowedAsciiChars.contains(char)) {
          result.write(char); // Allowed ASCII, write directly
        } else {
          // Disallowed ASCII, percent-encode
          result.write(
            '%${byte.toRadixString(16).toUpperCase().padLeft(2, '0')}',
          );
        }
      } else {
        // Non-ASCII byte (part of a UTF-8 sequence), always percent-encode
        result.write(
          '%${byte.toRadixString(16).toUpperCase().padLeft(2, '0')}',
        );
      }
    }
    Uri.parse(result.toString());
    return result.toString();
  }

  /// Reconstructs the IRI string from its components.
  /// If [punycodeHost] is true, components will be percent-encoded according
  /// to URI rules (RFC 3986 / RFC 3987 Sec 3.1) and host Punycode-encoded.
  String _reconstruct({bool punycodeHost = false}) {
    final sb = StringBuffer();
    if (_scheme != null) {
      sb.write(_scheme);
      sb.write(':');
    }

    var effectiveHost = _host;
    // Apply Punycode to host if requested and needed
    if (punycodeHost &&
        effectiveHost != null &&
        effectiveHost.isNotEmpty &&
        effectiveHost.runes.any((r) => r > 127)) {
      try {
        effectiveHost = PunycodeCodec().encode(effectiveHost);
      } catch (e) {
        // Re-throwing error as decided for toUriString
        throw FormatException(
          "Punycode encoding failed for host '$_host': $e",
          e,
        );
      }
    }

    // Rebuild authority
    if (effectiveHost != null && effectiveHost.isNotEmpty) {
      sb.write('//');
      if (_userInfo != null) {
        // Encode userinfo if converting to URI-like string
        final encodedUserInfo =
            punycodeHost
                ? _percentEncodeUriComponentChars(
                  _userInfo!,
                  _uriUserInfoAllowed,
                )
                : _userInfo; // Use normalized IRI version otherwise
        sb.write(encodedUserInfo);
        sb.write('@');
      }
      sb.write(effectiveHost); // Already ASCII/lowercase if punycoded
      if (_port != null) {
        sb.write(':');
        sb.write(_port);
      }
    }

    // Path: Encode segments if converting to URI-like string
    String reconstructedPath;
    if (punycodeHost && _path.isNotEmpty) {
      final segments = _path.split('/');
      final encodedSegments =
          segments
              .map(
                (segment) => _percentEncodeUriComponentChars(
                  segment,
                  '$_uriUnreserved$_uriSubDelims:@',
                ),
              )
              .toList();
      // Re-join, preserving structure
      if (_path.startsWith('/')) {
        reconstructedPath = '/${encodedSegments.sublist(1).join('/')}';
      } else {
        reconstructedPath = encodedSegments.join('/');
      }
      if (_path.length > 1 &&
          _path.endsWith('/') &&
          !reconstructedPath.endsWith('/')) {
        reconstructedPath += '/';
      }
      // Handle path being just "/"
      if (_path == '/' && reconstructedPath.isEmpty) {
        reconstructedPath = '/';
      }
    } else {
      reconstructedPath = _path; // Use normalized IRI path
    }

    // Add path, ensuring leading '/' if authority present but path is relative/empty
    if (effectiveHost != null &&
        effectiveHost.isNotEmpty &&
        !reconstructedPath.startsWith('/') &&
        reconstructedPath.isNotEmpty) {
      sb.write('/');
    } else if (effectiveHost != null &&
        effectiveHost.isNotEmpty &&
        reconstructedPath.isEmpty) {
      // If authority is present, path must start with '/' even if empty
      reconstructedPath = '/';
    }
    sb.write(reconstructedPath);

    if (_query != null) {
      sb.write('?');
      // Encode query if converting to URI-like string
      final encodedQuery =
          punycodeHost
              ? _percentEncodeUriComponentChars(_query!, _uriQueryAllowed)
              : _query;
      sb.write(encodedQuery);
    }
    if (_fragment != null) {
      sb.write('#');
      // Encode fragment if converting to URI-like string
      final encodedFragment =
          punycodeHost
              ? _percentEncodeUriComponentChars(_fragment!, _uriFragmentAllowed)
              : _fragment;
      sb.write(encodedFragment);
    }
    return sb.toString();
  }

  /// Resolves a relative IRI reference against this IRI (acting as the base).
  /// Returns a new [IriRef] representing the resolved IRI.
  /// (Implementation based on RFC 3986, Section 5)
  IriRef resolve(String relativeReference) {
    // TODO: Implement relative IRI resolution (RFC 3986, Section 5.2)
    // This is a complex algorithm involving merging components based on the
    // structure of the relative reference.
    print('Warning: resolve() not fully implemented yet.');
    try {
      // Very naive approach for placeholder:
      final relativeIri = IriRef(relativeReference); // Parse the relative part
      // Use dart:core Uri for basic resolution logic (might not be fully IRI compliant)
      final baseUri = Uri.parse(
        _reconstruct(punycodeHost: true),
      ); // Convert base to URI
      final resolvedUri = baseUri.resolve(
        relativeReference,
      ); // Use Uri's resolver
      return IriRef(
        resolvedUri.toString(),
      ); // Parse the result back into an IriRef
    } catch (e) {
      print('Error during naive resolution: $e');
      // Fallback or rethrow? Fallback to simple concatenation might be wrong.
      return IriRef(originalValue + relativeReference); // Very basic fallback
    }
  }

  /// Returns a new [IriRef] by resolving the given [IriRef] against this one.
  IriRef resolveUri(IriRef reference) {
    // Delegate to the string-based resolve, using the relative IriRef's original string.
    return resolve(reference.originalValue);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! IriRef) return false;
    // Compare the *normalized* components for equality.
    return _scheme == other._scheme &&
        _userInfo == other._userInfo &&
        _host == other._host &&
        _port == other._port &&
        _path == other._path && // Path normalization is now done
        _query == other._query &&
        _fragment == other._fragment;
  }

  @override
  int get hashCode {
    // Compute hash code based on the *normalized* components.
    return Object.hash(
      _scheme,
      _userInfo,
      _host,
      _port,
      _path, // Path normalization is now done
      _query,
      _fragment,
    );
  }

  /// Returns the reconstructed, normalized IRI string from its components.
  /// This provides a canonical representation based on syntax normalization.
  /// For the strict URI string representation (including Punycode and
  /// full percent-encoding), use [toUriString].
  @override
  String toString() {
    // Reconstruct from normalized components for a canonical IRI string output.
    return _reconstruct();
  }
}
