/// Generates permutations of a list using the Steinhaus-Johnson-Trotter algorithm.
///
/// Takes a list of comparable elements (e.g., Strings) and provides an
/// iterator interface (`moveNext`, `current`) to retrieve all permutations.
/// Each permutation differs from the previous one by a single adjacent swap.
///
/// Conforms to the standard `dart:core` [Iterator] interface.
class Permuter<T extends Comparable<T>> implements Iterator<List<T>> {
  final List<_SjtElement<T>> _elements;
  List<T>? _currentPermutation; // Stores the current permutation
  bool _isInitialState = true; // Flag for the first call to moveNext

  /// Creates a Permuter for the given list.
  ///
  /// The input [list] will be sorted initially. The iterator starts
  /// *before* the first element. Call [moveNext] once to move to the
  /// first permutation.
  Permuter(List<T> list) : _elements = [] {
    if (list.isEmpty) {
      // If the input list is empty, there are no permutations.
      _currentPermutation = null;
      _isInitialState = false; // No initial state to move to
      return;
    }
    // Create a sorted copy to avoid modifying the original list
    final sortedList = List<T>.from(list)..sort();
    // Initialize elements with direction left (true)
    for (final item in sortedList) {
      _elements.add(
        _SjtElement(item, isDirectionLeft: true),
      ); // Initial direction: Left
    }
    // Initial state: iterator points *before* the first element.
    _currentPermutation = null;
  }

  /// The current permutation.
  ///
  /// Returns the current element. Throws [StateError] if the iterator
  /// is not pointing to a valid element (e.g., before the first call
  /// to [moveNext], or after [moveNext] returns `false`).
  @override
  List<T> get current {
    if (_currentPermutation == null) {
      // Check if it's the initial state or if iteration finished.
      // Note: Could refine this check if distinguishing between start/end matters.
      throw StateError('Iterator is not pointing to a valid element.');
    }
    return _currentPermutation!;
  }

  /// Moves to the next permutation.
  ///
  /// Returns `true` if there is a next permutation, and `false` otherwise.
  ///
  /// The [current] getter should only be used after [moveNext] has been
  /// called and returned `true`.
  @override
  bool moveNext() {
    // Handle the very first call
    if (_isInitialState) {
      _isInitialState = false; // No longer initial state
      if (_elements.isEmpty) {
        // Empty input list case
        _currentPermutation = null;
        return false;
      }
      // Set the initial permutation (the sorted list)
      _currentPermutation = _elements.map((e) => e.value).toList();
      return true; // Successfully moved to the first element
    }

    // If already finished, return false
    if (_currentPermutation == null) {
      // Happens if moveNext was called after it already returned false
      return false;
    }

    // Calculate the *next* permutation using SJT algorithm

    // 2a. Find the largest mobile element k
    _SjtElement<T>? kElement;
    var kPos = -1;
    for (var i = 0; i < _elements.length; i++) {
      final currentElement = _elements[i];
      final direction = currentElement.isDirectionLeft;
      final comparePos = direction ? i - 1 : i + 1;

      var isMobile = false;
      if (direction &&
          i > 0 &&
          currentElement.value.compareTo(_elements[comparePos].value) > 0) {
        // Mobile moving left
        isMobile = true;
      } else if (!direction &&
          i < _elements.length - 1 &&
          currentElement.value.compareTo(_elements[comparePos].value) > 0) {
        // Mobile moving right
        isMobile = true;
      }

      if (isMobile &&
          (kElement == null ||
              currentElement.value.compareTo(kElement.value) > 0)) {
        kElement = currentElement;
        kPos = i;
      }
    }

    // 2b. If no mobile element found, we are done
    if (kElement == null) {
      _currentPermutation = null; // Indicate iteration finished
      return false; // No more permutations
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

      // Update currentPermutation to the newly calculated state
      _currentPermutation = _elements.map((e) => e.value).toList();
      return true; // Successfully moved to the next permutation
    }
  }
}

/// Helper class to store an element and its direction for the SJT algorithm.
class _SjtElement<T extends Comparable<T>> {
  T value;
  bool isDirectionLeft; // true = left, false = right

  _SjtElement(this.value, {required this.isDirectionLeft});
}
