import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../utils/storage.dart';
import '../../models/cart.dart';
import 'cart_detail.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Cart> carts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCarts();
  }

  Future<void> fetchCarts() async {
    final token = await Storage.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/carts');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    });

    if (!mounted) return;

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;

      setState(() {
        carts = data.map((json) => Cart.fromJson(json)).toList();
        isLoading = false;
      });
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat keranjang')),
        );
      }
    }
  }

  final Map<String, String> statusMap = {
    'active': 'Aktif',
    'submitted': 'Dikirim',
    'canceled': 'Dibatalkan'
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Saya', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchCarts,
              child: carts.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 200),
                        Center(
                          child: Text(
                            'Tidak ada keranjang',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: carts.length,
                      itemBuilder: (context, index) {
                        final cart = carts[index];
                        final unitCount = cart.cartItems.length;
                        final status = statusMap[cart.status] ?? cart.status;

                        Color statusColor;
                        switch (cart.status) {
                          case 'active':
                            statusColor = Colors.green;
                            break;
                          case 'submitted':
                            statusColor = Colors.orange;
                            break;
                          case 'canceled':
                            statusColor = Colors.red;
                            break;
                          default:
                            statusColor = Colors.grey;
                        }

                        return Container(
                          margin:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'Keranjang ${cart.id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Jumlah Unit: $unitCount'),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Text('Status: '),
                                      Text(
                                        status,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CartDetail(
                                    cart: cart,
                                    initialCartItems: cart.cartItems,
                                  ),
                                ),
                              ).then((_) {
                                fetchCarts();
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
