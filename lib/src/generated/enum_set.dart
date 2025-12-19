abstract class EnumSet<T extends Enum> {
  int rawValue = 0;

  EnumSet();

  bool contains(T value);

  bool containsAll(Iterable<T> other) => other.every(this.contains);

  bool containsAllFromEnumSet(EnumSet<T> other);

  bool isEmpty() => this.rawValue == 0;

  bool isNotEmpty() => this.rawValue != 0;

  bool add(T value);

  void addAll(Iterable<T> elements) => elements.forEach(this.add);

  void addAllFromEnumSet(EnumSet<T> other);

  bool remove(T value);

  void removeAll(Iterable<T> elements) => elements.forEach(this.remove);

  void removeAllFromEnumSet(EnumSet<T> other);

  EnumSet<T> intersection(EnumSet<T> other);

  EnumSet<T> union(EnumSet<T> other);

  EnumSet<T> difference(EnumSet<T> other);

  void clear() {
    this.rawValue = 0;
  }

  Set<T> toSet();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnumSet &&
          this.runtimeType == other.runtimeType &&
          this.rawValue == other.rawValue;

  @override
  int get hashCode => this.rawValue.hashCode;
}
