import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../utils/storage.dart';
import '../../config/api_config.dart';
import '../../models/borrowing.dart';

class BorrowPage extends StatefulWidget {
  const BorrowPage({super.key});

  @override
  State<BorrowPage> createState() => _BorrowPageState();
}

class _BorrowPageState extends State<BorrowPage> {
  List<Borrowing> borrowings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBorrowings();
  }

  Future<void> fetchBorrowings() async {
    final token = await Storage.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/borrowings');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'];

      setState(() {
        borrowings = list.map((e) => Borrowing.fromJson(e)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat peminjaman: ${response.body}')),
      );
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu Persetujuan';
      case 'approved':
        return 'Sedang Dipinjam';
      case 'returned':
        return 'Sudah Dikembalikan';
      default:
        return 'Status Tidak Dikenal';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'returned':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Peminjaman', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : borrowings.isEmpty
              ? const Center(child: Text('Tidak ada data peminjaman.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: borrowings.length,
                  itemBuilder: (context, index) {
                    final borrow = borrowings[index];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            'ID Peminjaman: ${borrow.id}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),

                        ...borrow.units.map((unit) {
                          final item = unit.item;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.white,
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
                                              const Icon(Icons.broken_image),
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
                                      Text('ID Unit: ${unit.id}'),
                                      Text('Kode Unit: ${unit.unitCode}'),
                                      Text('Peminjaman: ${borrow.borrowedAt}'),
                                      Text('Pengembalian: ${borrow.returnedAt}'),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          _statusText(borrow.status),
                                          style: TextStyle(
                                            color: _statusColor(borrow.status),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (borrow.returnedAt.isEmpty)
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      side: const BorderSide(color: Colors.grey),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      backgroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      // TODO: navigate to ReturnRequest or custom handler
                                    },
                                    child: const Text('Kembalikan'),
                                  ),
                              ],
                            ),
                          );
                        }),
                        const Divider(),
                      ],
                    );
                  },
                ),
    );
  }
}