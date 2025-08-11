import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../config/api_config.dart';
import '../../utils/storage.dart';
import '../../models/cart.dart';
import '../../models/borrowing.dart';
import '../transactions/borrow_request.dart';
import '../transactions/return_request.dart';

class CartDetail extends StatefulWidget {
  final Cart cart;
  final List<CartItem> initialCartItems;

  const CartDetail({
    super.key,
    required this.cart,
    required this.initialCartItems,
  });

  @override
  State<CartDetail> createState() => _CartDetailState();
}

class _CartDetailState extends State<CartDetail> {
  late List<CartItem> cartItems;
  Borrowing? borrowing;
  bool isLoadingBorrowing = false;

  @override
  void initState() {
    super.initState();
    cartItems = [...widget.initialCartItems];
    if (widget.cart.status == 'submitted') {
      fetchBorrowingByCart();
    }
  }

  Future<void> fetchCartItems() async {
    final token = await Storage.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/carts/${widget.cart.id}');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final newCartItems = (jsonData['data']['cart_items'] as List)
          .map((e) => CartItem.fromJson(e))
          .toList();

      if (mounted) {
        setState(() {
          cartItems = newCartItems;
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat ulang keranjang')),
        );
      }
    }
  }

  Future<void> fetchBorrowingByCart() async {
    setState(() => isLoadingBorrowing = true);
    final token = await Storage.getToken();
    final url =
        Uri.parse('${ApiConfig.baseUrl}/carts/${widget.cart.id}/borrowing');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    });

    if (!mounted) return;

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      setState(() {
        borrowing = Borrowing.fromJson(jsonData['data']);
        isLoadingBorrowing = false;
      });
    } else {
      setState(() => isLoadingBorrowing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data peminjaman')),
      );
    }
  }

  void removeItem(int cartItemId) async {
    final token = await Storage.getToken();
    final url = Uri.parse(
        '${ApiConfig.baseUrl}/carts/${widget.cart.id}/remove-item/$cartItemId'
    );

    final response = await http.delete(url, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    });

    if (!mounted) return;

    if (response.statusCode == 200) {
      setState(() {
        cartItems.removeWhere((item) => item.unitId == cartItemId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unit $cartItemId dihapus dari keranjang')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus unit')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Keranjang ${widget.cart.id}'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (widget.cart.status == 'submitted') {
            await fetchBorrowingByCart();
          }
          await fetchCartItems();
          setState(() {});
        },
        child: cartItems.isEmpty
            ? const Center(child: Text('Keranjang kosong'))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: cartItems.length + 1,
                itemBuilder: (context, index) {
                  if (index == cartItems.length) {
                    if (widget.cart.status == 'canceled') {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.send, color: Colors.blue),
                        label: Text(
                          widget.cart.status == 'submitted'
                              ? 'Ajukan Pengembalian'
                              : 'Ajukan Peminjaman',
                          style: const TextStyle(color: Colors.blue),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          minimumSize: const Size.fromHeight(50),
                          textStyle: const TextStyle(fontSize: 16),
                          elevation: 0,
                        ),
                        onPressed: widget.cart.status == 'submitted'
                            ? (borrowing == null || isLoadingBorrowing
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ReturnRequest(borrowing: borrowing!),
                                      ),
                                    );
                                  })
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BorrowRequest(cart: widget.cart),
                                  ),
                                );
                              },
                      ),
                    );
                  }

                  final cartItem = cartItems[index];
                  final unit = cartItem.unit;
                  final item = unit.item;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: item.image != null && item.image!.isNotEmpty
                              ? Image.network(
                                  'http://127.0.0.1:8000/storage/${item.image}',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 40),
                                )
                              : const Icon(Icons.image_not_supported, size: 40),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('Kode: ${unit.unitCode}'),
                              Text('ID Unit: ${unit.id}'),
                              Text('Lokasi: ${unit.location.name}'),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => removeItem(cartItem.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}