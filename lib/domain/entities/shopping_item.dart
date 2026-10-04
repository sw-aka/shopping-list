class ShoppingItem {
  const ShoppingItem({
    required this.id,
    required this.name,
    this.done = false,
  });

  final String id;
  final String name;
  final bool done;

  ShoppingItem copyWith({String? name, bool? done}) => ShoppingItem(
        id: id,
        name: name ?? this.name,
        done: done ?? this.done,
      );

  @override
  bool operator ==(Object other) =>
      other is ShoppingItem &&
      other.id == id &&
      other.name == name &&
      other.done == done;

  @override
  int get hashCode => Object.hash(id, name, done);

  @override
  String toString() => 'ShoppingItem(id: $id, name: $name, done: $done)';
}
