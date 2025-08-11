import 'unit.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String origin;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.origin,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        role: json['role'],
        origin: json['origin'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'origin': origin,
      };
}

class Cart {
  final int id;
  final int userId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User user;
  final List<CartItem> cartItems;

  Cart({
    required this.id,
    required this.userId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.cartItems,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        id: json['id'],
        userId: json['user_id'],
        status: json['status'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        user: User.fromJson(json['user']),
        cartItems: (json['cart_items'] as List<dynamic>?)
          ?.map((e) => CartItem.fromJson(e)).toList() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'user': user.toJson(),
        'cart_items': cartItems.map((e) => e.toJson()).toList(),
      };
}

class CartItem {
  final int id;
  final int cartId;
  final int unitId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Unit unit;

  CartItem({
    required this.id,
    required this.cartId,
    required this.unitId,
    required this.createdAt,
    required this.updatedAt,
    required this.unit,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'],
        cartId: json['cart_id'],
        unitId: json['unit_id'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        unit: Unit.fromJson(json['unit']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'cart_id': cartId,
        'unit_id': unitId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'unit': unit.toJson(),
      };
}