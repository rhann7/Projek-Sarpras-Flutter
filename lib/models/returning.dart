import 'unit.dart';
import 'borrowing.dart';

class ReturningDetail {
  final int unitId;
  final String status;
  final Unit unit;

  ReturningDetail({
    required this.unitId,
    required this.status,
    required this.unit,
  });

  factory ReturningDetail.fromJson(Map<String, dynamic> json) {
    return ReturningDetail(
      unitId: json['unit_id'],
      status: json['status'],
      unit: Unit.fromJson(json['unit']),
    );
  }
}

class Returning {
  final int id;
  final int userId;
  final int borrowingId;
  final String returnedAt;
  final String? description;
  final List<ReturningDetail> details;
  final Borrowing? borrowing;

  Returning({
    required this.id,
    required this.userId,
    required this.borrowingId,
    required this.returnedAt,
    this.description,
    required this.details,
    this.borrowing,
  });

  List<Unit> get units => details.map((detail) => detail.unit).toList();

  factory Returning.fromJson(Map<String, dynamic> json) {
    List<ReturningDetail> details = [];

    if (json['details'] != null) {
      for (var detail in (json['details'] as List)) {
        details.add(ReturningDetail.fromJson(detail));
      }
    }

    return Returning(
      id: json['id'],
      userId: json['user_id'],
      borrowingId: json['borrowing_id'],
      returnedAt: json['returned_at'] ?? '',
      description: json['description'],
      details: details,
      borrowing: json['borrowing'] != null
          ? Borrowing.fromJson(json['borrowing'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'borrowing_id': borrowingId,
      'returned_at': returnedAt,
      'description': description,
      'details': details.map((detail) => {
        'unit_id': detail.unitId,
        'status': detail.status,
      }).toList(),
    };
  }
}