import 'unit.dart';

class Borrowing {
  final int id;
  final int cartId;
  final String borrowedAt;
  final String returnedAt;
  final String status;
  final String? description;
  final List<Unit> units;

  Borrowing({
    required this.id,
    required this.cartId,
    required this.borrowedAt,
    required this.returnedAt,
    required this.status,
    this.description,
    required this.units,
  });

  factory Borrowing.fromJson(Map<String, dynamic> json) {
    List<Unit> units = [];
    
    if (json['details'] != null) {
      for (var detail in (json['details'] as List)) {
        final unit = detail['unit'];
        if (unit != null) {
          units.add(Unit.fromJson(unit));
        }
      }
    }

    return Borrowing(
      id: json['id'],
      cartId: json['cart_id'],
      borrowedAt: json['borrowed_at'],
      returnedAt: json['returned_at'],
      status: json['status'] ?? 'pending',
      description: json['description'] ?? '',
      units: units,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_id': cartId,
      'borrow_start': borrowedAt,
      'borrow_end': returnedAt,
      'status': status,
      'description': description,
      'unit_ids': units.map((unit) => unit.id).toList(),
    };
  }
}