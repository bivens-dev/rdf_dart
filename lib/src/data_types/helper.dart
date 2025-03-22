/// An enum to indicate the appropriate whitespace processing rules as
/// outlined in https://www.w3.org/TR/xmlschema11-2/#rf-whiteSpace
enum Whitespace {
  /// No normalization is done, the value is not changed
  /// (this is the behavior required by `XML` for element content)
  preserve,

  /// All occurrences of (tab), (line feed) and (carriage return)
  /// are replaced with (space)
  replace,

  /// After the processing implied by replace, contiguous sequences of spaces
  /// are collapsed to a single space, and any space at the start or end of
  /// the string is then removed.
  collapse,
}

/// A function that processes white space according to the rules outlined
/// in https://www.w3.org/TR/xmlschema11-2/#rf-whiteSpace
String processWhiteSpace(String input, Whitespace whitespace) {
  if (input.isEmpty || whitespace == Whitespace.preserve) {
    return input;
  }

  if (whitespace == Whitespace.replace || whitespace == Whitespace.collapse) {
    // Replaces all occurrences of tab (#x9), line feed (#xA),
    // and carriage return (#xD) characters in the input
    // string with spaces (#x20).
    input = input.replaceAll(RegExp(r'[\x09\x0A\x0D]', unicode: true), ' ');
  }

  if (input.isEmpty) {
    return input;
  }

  if (whitespace == Whitespace.collapse) {
    // Use a regular expression to replace multiple spaces with a single space.
    input = input.replaceAll(RegExp(' +'), ' ');

    // Trim leading and trailing spaces.
    input = input.trim();
  }

  return input;
}
