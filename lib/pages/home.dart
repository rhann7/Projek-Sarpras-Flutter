import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/api_config.dart';
import '../utils/storage.dart';
import '../models/item.dart';

import 'unit/unit.dart';
import 'carts/cart.dart';
import 'account/account.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Item> items = [];
  List<Item> filteredItems = [];
  List<String> availableBrands = [];
  List<String> availableCategories = [];

  String searchQuery = '';
  String? selectedFilterType;
  String? selectedFilterValue;

  bool isLoading = true;
  int _selectedIndex = 0;

  TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> disposableOptions = [
    {'lable': 'Bisa Dipakai Kembali', 'value': false},
    {'lable': 'Sekali Pakai', 'value': true},
  ];

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchItems() async {
    final token = await Storage.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/items');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'];

      final brands = list
          .map((e) => e['brand'] ?? '').toSet().where((b) => b != '').toList();

      final categories = list
          .map((e) => e['category']?['name'] ?? '').toSet().where((c) => c != '').toList();

      setState(() {
        items = list.map((e) => Item.fromJson(e)).toList();
        filteredItems = items;
        availableBrands = List<String>.from(brands);
        availableCategories = List<String>.from(categories);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memuat barang')));
    }
  }

  void applyFilters() {
    List<Item> tempItems = items;

    if (searchQuery.isNotEmpty) {
      tempItems = tempItems.where((item) => item.name.toLowerCase().contains(searchQuery)).toList();
    }

    if (selectedFilterType != null && selectedFilterValue != null) {
      if (selectedFilterType == 'brand') {
        tempItems = tempItems.where((item) => item.brand == selectedFilterValue).toList();
      } else if (selectedFilterType == 'disposable') {
        tempItems = tempItems.where((item) => item.reusable.toString() == selectedFilterValue).toList();
      } else if (selectedFilterType == 'category') {
        tempItems = tempItems.where((item) => item.category?.name == selectedFilterValue).toList();
      }
    }

    setState(() {
      filteredItems = tempItems;
    });
  }

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget homePage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
                applyFilters();
              });
            },
            decoration: InputDecoration(
              hintText: 'Cari barang...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedFilterType,
                  decoration: InputDecoration(
                    labelText: 'Filter Berdasarkan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Tidak Ada')),
                    DropdownMenuItem(value: 'brand', child: Text('Merek')),
                    DropdownMenuItem(value: 'category', child: Text('Kategori Barang')),
                    DropdownMenuItem(value: 'disposable', child: Text('Jenis Barang'))
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedFilterType = value;
                      selectedFilterValue = null;
                      applyFilters();
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedFilterValue,
                  decoration: InputDecoration(
                    labelText: 'Nilai',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  items: selectedFilterType == 'brand'
                      ? availableBrands.map((brand) => DropdownMenuItem(value: brand, child: Text(brand))).toList()
                      : selectedFilterType == 'disposable'
                          ? disposableOptions.map((opt) => DropdownMenuItem(value: opt['value'].toString(), child: Text(opt['lable']))).toList()
                      : selectedFilterType == 'category'
                          ? availableCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList()
                      : [],
                  onChanged: (value) {
                    setState(() {
                      selectedFilterValue = value;
                      applyFilters();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1 / 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UnitPage(item: item)),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                                child: Image.network(
                                  'http://127.0.0.1:8000/storage/${item.image}',
                                  height: 80,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(child: Icon(Icons.broken_image, size: 40)),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (item.category != null)
                                    Text(
                                      'Kategori: ${item.category!.name}',
                                      style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 55, 55, 55)),
                                    ),
                                  Text(
                                    'Tipe: ${item.reusable ? "Sekali Pakai" : "Bisa Digunakan Kembali"}',
                                    style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 55, 55, 55)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      homePage(),
      const CartPage(),
      const AccountPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sarpras SMK Taruna Bhakti',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Keranjang'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
        ],
      ),
    );
  }
}