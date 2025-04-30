/// Generates permutations of a list using the Steinhaus-Johnson-Trotter algorithm.
///
/// Takes a list of comparable elements (e.g., Strings) and provides an
/// iterator-style interface (`hasNext`, `next`) to retrieve all permutations.
/// Each permutation differs from the previous one by a single adjacent swap.
class Permuter<T extends Comparable<T>> {
  final List<_SjtElement<T>> _elements;
  bool _done = false;

  /// Creates a Permuter for the given list.
  ///
  /// The input [list] will be sorted initially.
  Permuter(List<T> list) : _elements = [] {
    if (list.isEmpty) {
      _done = true;
      return;
    }
    // Create a sorted copy to avoid modifying the original list
    final sortedList = List<T>.from(list)..sort();
    // Initialize elements with direction left (true)
    for (final item in sortedList) {
      _elements.add(_SjtElement(item, isDirectionLeft: true)); // Initial direction: Left
    }
  }

  /// Returns true if there are more permutations available.
  bool hasNext() {
    return !_done;
  }

  /// Returns the next permutation as a `List<T>`.
  ///
  /// Returns null if no more permutations exist.
  List<T>? next() {
    if (_done) {
      return null;
    }

    // 1. Return a copy of the current permutation's values
    final currentPermutation = _elements.map((e) => e.value).toList();

    // 2. Calculate the next permutation using SJT algorithm

    // 2a. Find the largest mobile element k
    _SjtElement<T>? kElement;
    var kPos = -1;
    for (var i = 0; i < _elements.length; i++) {
      final currentElement = _elements[i];
      final direction = currentElement.isDirectionLeft;
      final comparePos = direction ? i - 1 : i + 1;

      var isMobile = false;
      if (direction && i > 0 && currentElement.value.compareTo(_elements[comparePos].value) > 0) {
        // Mobile moving left
        isMobile = true;
      } else if (!direction && i < _elements.length - 1 && currentElement.value.compareTo(_elements[comparePos].value) > 0) {
        // Mobile moving right
        isMobile = true;
      }

      if (isMobile && (kElement == null || currentElement.value.compareTo(kElement.value) > 0)) {
        kElement = currentElement;
        kPos = i;
      }
    }

    // 2b. If no mobile element found, we are done
    if (kElement == null) {
      _done = true;
    } else {
      // 2c. Swap k with the element it's looking at
      final swapPos = kElement.isDirectionLeft ? kPos - 1 : kPos + 1;
      final temp = _elements[kPos];
      _elements[kPos] = _elements[swapPos];
      _elements[swapPos] = temp;

      // 2d. Reverse the direction of all elements larger than k
      for (final element in _elements) {
        if (element.value.compareTo(kElement.value) > 0) {
          element.isDirectionLeft = !element.isDirectionLeft;
        }
      }
    }

    return currentPermutation;
  }
}

/// Helper class to store an element and its direction for the SJT algorithm.
class _SjtElement<T extends Comparable<T>> {
  T value;
  bool isDirectionLeft; // true = left, false = right

  _SjtElement(this.value, {required this.isDirectionLeft});
}