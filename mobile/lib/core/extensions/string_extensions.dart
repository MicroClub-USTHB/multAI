extension StringX on String {
  String get capitalize {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  String get capitalizeWords {
    return split(" ").map((str) => str.capitalize).join(" ");
  }
}
