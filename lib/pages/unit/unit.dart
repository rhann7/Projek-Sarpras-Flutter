import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../utils/storage.dart';
import '../../models/item.dart';
import '../../models/unit.dart';

class UnitPage extends StatefulWidget {
  final Item item;

  const UnitPage({super.key, required this.item});

  @override
  State<UnitPage> createState() => _UnitPageState();
}

class _UnitPageState extends State<UnitPage> {
  List<Unit> units = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUnits();
  }

  Future<void> fetchUnits() async {
    final token = await Storage.getToken();
    final url = Uri.parse(
        '${ApiConfig.baseUrl}/units?filter_type=item&filter_value=${widget.item.id}&order=asc');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    });

    if (!mounted) return;

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final List unitList = responseData['data'] is List
        ? responseData['data']
        : responseData['data']['data'];

      setState(() {
        units = unitList.map((json) => Unit.fromJson(json)).toList();
        isLoading = false;
      });
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat unit')),
        );
      }
    }
  }

  Future<int?> getOrCreateCart() async {
    final token = await Storage.getToken();
    final getCartUrl =
        Uri.parse('${ApiConfig.baseUrl}/carts/get-or-create-cart');
    final response = await http.get(getCartUrl, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final cartId = data['data']['id'];
      return cartId;
    } else {
      return null;
    }
  }

  Future<void> addItem(int cartId, int unitId) async {
    final token = await Storage.getToken();
    final addItemUrl = Uri.parse('${ApiConfig.baseUrl}/carts/$cartId/add-item');
    final response = await http.post(addItemUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'unit_id': [unitId]
        }));

    if (!mounted) return;

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil ditambahkan ke keranjang')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menambahkan ke keranjang')),
      );
    }
  }

  Future<void> onAddToCartPressed(int unitId) async {
    final cartId = await getOrCreateCart();
    if (cartId != null) {
      await addItem(cartId, unitId);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuat keranjang')),
      );
    }
  }

  final Map<String, String> statusMap = {
    'available': 'Tersedia',
    'reserved': 'Dipesan',
    'borrowed': 'Dipinjam',
    'used': 'Terpakai',
    'repaired': 'Dalam Perbaikan',
  };

  final Map<String, String> conditionMap = {'good': 'Baik', 'broken': 'Rusak'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unit dari ${widget.item.name}'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : units.isEmpty
              ? const Center(child: Text('Tidak ada unit tersedia'))
              : ListView.builder(
                  itemCount: units.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    final unit = units[index];

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      padding: const EdgeInsets.all(12),
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
                            child: unit.item.image != null && unit.item.image!.isNotEmpty
                                ? Image.network(
                                    'http://127.0.0.1:8000/storage/${unit.item.image}',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.broken_image, size: 40),
                                  )
                                : const Icon(Icons.image_not_supported, size: 60),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Unit ${unit.unitCode}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 15)),
                                const SizedBox(height: 6),
                                Text('ID Barang: ${unit.id}'),
                                Text('Kondisi: ${conditionMap[unit.condition]}'),
                                Text('Status: ${statusMap[unit.status]}'),
                                Text('Lokasi: ${unit.location.name}'),
                                const SizedBox(height: 10),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.add_shopping_cart, color: Colors.blue),
                                  label: const Text(
                                    'Tambahkan ke Keranjang',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.blue),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () => onAddToCartPressed(unit.id),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}