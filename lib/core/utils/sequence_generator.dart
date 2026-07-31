import 'dart:math';

/// Fisher–Yates shuffle producing a new list (does not mutate [input]).
List<T> fisherYatesShuffle<T>(List<T> input, [Random? random]) {
  final rng = random ?? Random();
  final list = List<T>.from(input);
  for (var i = list.length - 1; i > 0; i--) {
    final j = rng.nextInt(i + 1);
    final tmp = list[i];
    list[i] = list[j];
    list[j] = tmp;
  }
  return list;
}

/// Generates a random permutation of [length] distinct indices from
/// `0 .. activeCount-1` using Fisher–Yates. No duplicates.
List<int> generateSequence(int activeCount, int length, [Random? random]) {
  assert(length >= 1 && length <= activeCount);
  final indices = List<int>.generate(activeCount, (i) => i);
  final shuffled = fisherYatesShuffle(indices, random);
  return shuffled.sublist(0, length);
}
