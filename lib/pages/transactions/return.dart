import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../utils/storage.dart';
import '../../config/api_config.dart';
import '../../models/returning.dart';

class ReturnPage extends StatefulWidget {
  const ReturnPage({super.key});

  @override
  State<ReturnPage> createState() => _ReturnPageState();
}

class _ReturnPageState extends State<ReturnPage> {
  List<Returning> returnings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReturned();
  }

  Future<void> fetchReturned() async {
    final token = await Storage.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/returnings');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    if (!mounted) return;

    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body)['data'];

      setState(() {
        returnings = list.map((e) => Returning.fromJson(e)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat pengembalian')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pengembalian', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : returnings.isEmpty
              ? const Center(child: Text('Belum ada barang dikembalikan.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: returnings.length,
                  itemBuilder: (context, index) {
                    final returning = returnings[index];
                    final borrowing = returning.borrowing;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID Pengembalian: ${returning.id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              )),
                          const SizedBox(height: 4),
                          Text('ID Peminjaman: ${borrowing?.id ?? "-"}'),
                          Text('Tanggal Pinjam: ${borrowing?.borrowedAt ?? "-"}'),
                          Text('Tanggal Kembali: ${returning.returnedAt}'),
                          if (returning.description?.isNotEmpty == true)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('Deskripsi: ${returning.description}'),
                            ),
                          const SizedBox(height: 8),
                          const Text(
                            'Unit yang Dikembalikan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...returning.details.map((detail) {
                            final item = detail.unit.item;
                            final location = detail.unit.location;
                            final isReturned = detail.status == 'returned';
                            final statusText = isReturned ? 'Dikembalikan' : 'Terpakai';
                            final statusColor = isReturned ? Colors.green : Colors.orange;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(6),
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
                                        Text(item.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            )),
                                        const SizedBox(height: 4),
                                        Text('Lokasi: ${location.name}'),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(color: statusColor),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            statusText,
                                            style: TextStyle(
                                              color: statusColor,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}