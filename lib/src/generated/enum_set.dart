abstract class EnumSet<T extends Enum> {
  final int rawValue;

  const EnumSet([this.rawValue = 0]);

  bool contains(T value);

  bool containsAll(Iterable<T> other) => other.every(this.contains);

  bool containsAllFromEnumSet(EnumSet<T> other);

  bool isEmpty() => this.rawValue == 0;

  bool isNotEmpty() => this.rawValue != 0;

  EnumSet<T> intersection(EnumSet<T> other);

  EnumSet<T> union(EnumSet<T> other);

  EnumSet<T> difference(EnumSet<T> other);

  MutableEnumSet<T> toMutableEnumSet();

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

abstract class MutableEnumSet<T extends Enum> {
  int rawValue = 0;

  MutableEnumSet();

  bool contains(T value);

  bool containsAll(Iterable<T> other) => other.every(this.contains);

  bool containsAllFromEnumSet(MutableEnumSet<T> other);

  bool isEmpty() => this.rawValue == 0;

  bool isNotEmpty() => this.rawValue != 0;

  bool add(T value);

  void addAll(Iterable<T> elements) => elements.forEach(this.add);

  void addAllFromEnumSet(MutableEnumSet<T> other);

  bool remove(T value);

  void removeAll(Iterable<T> elements) => elements.forEach(this.remove);

  void removeAllFromEnumSet(MutableEnumSet<T> other);

  MutableEnumSet<T> intersection(MutableEnumSet<T> other);

  MutableEnumSet<T> union(MutableEnumSet<T> other);

  MutableEnumSet<T> difference(MutableEnumSet<T> other);

  void clear() {
    this.rawValue = 0;
  }

  EnumSet<T> toEnumSet();

  Set<T> toSet();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MutableEnumSet &&
          this.runtimeType == other.runtimeType &&
          this.rawValue == other.rawValue;

  @override
  int get hashCode => this.rawValue.hashCode;
}
