import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../config/api_config.dart';
import '../../utils/storage.dart';
import '../../models/borrowing.dart';

class ReturnRequest extends StatefulWidget {
  final Borrowing borrowing;

  const ReturnRequest({super.key, required this.borrowing});

  @override
  State<ReturnRequest> createState() => _ReturnRequestState();
}

class _ReturnRequestState extends State<ReturnRequest> {
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _submitReturn(int unitId, String status) async {
    final token = await Storage.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/returnings');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'borrowing_id': widget.borrowing.id,
        'description': _descriptionController.text,
        'details': [
          {
            'unit_id': unitId,
            'status': status,
          }
        ],
      }),
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Berhasil diproses')),
      );
      setState(() {
        widget.borrowing.units.removeWhere((u) => u.id == unitId);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final units = widget.borrowing.units;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajukan Pengembalian'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Keterangan Pengembalian',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ),
          Expanded(
            child: units.isEmpty
                ? const Center(
                    child: Text(
                      'Semua unit sudah dikembalikan.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: units.length,
                    itemBuilder: (context, index) {
                      final unit = units[index];
                      final item = unit.item;
                      final reusable = item.reusable == true;

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                                        fontSize: 16,
                                      )),
                                  const SizedBox(height: 4),
                                  Text('ID Unit: ${unit.id}'),
                                  Text('Kode: ${unit.unitCode}'),
                                  Text('Lokasi: ${unit.location.name}'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () {
                                final status = reusable ? 'used' : 'returned';
                                _submitReturn(unit.id, status);
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.blue),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: Text(
                                reusable ? 'Selesai' : 'Kembalikan',
                                style: const TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}