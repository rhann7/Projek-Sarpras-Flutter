import 'item.dart';

class Location {
  final int id;
  final String name;

  Location({required this.id, required this.name});

  factory Location.fromJson(Map<String, dynamic> json) =>
      Location(id: json['id'], name: json['name']);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class Unit {
  final int id;
  final String unitCode;
  final String condition;
  final String status;
  final Location location;
  final Item item;

  Unit({
    required this.id,
    required this.unitCode,
    required this.condition,
    required this.status,
    required this.location,
    required this.item,
  });

  factory Unit.fromJson(Map<String, dynamic> json) => Unit(
    id: json['id'],
    unitCode: json['unit_code'],
    condition: json['condition'],
    status: json['status'],
    location: Location.fromJson(json['location']),
    item: Item.fromJson(json['item']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'unit_code': unitCode,
    'condition': condition,
    'status': status,
    'location': location.toJson(),
    'item': item.toJson(),
  };
}