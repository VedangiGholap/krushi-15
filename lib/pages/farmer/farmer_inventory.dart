import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'add_product.dart';

class InventoryPage extends StatefulWidget {
  final String farmerId;

  const InventoryPage({super.key, required this.farmerId});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Inventory"),
        backgroundColor: Colors.green[600],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          final _ = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProductPage(farmerId: widget.farmerId),
            ),
          );


          // The page will automatically update with StreamBuilder, no need to call fetchProducts.
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: "Search crops...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) {
                setState(() {
                  searchQuery = val;
                });
              },
            ),
            const SizedBox(height: 16),

            // Real-Time Product List using StreamBuilder
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('inventory')
                    .where('farmerId', isEqualTo: widget.farmerId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final products = snapshot.data!.docs;

                  // Filter products based on search query
                  final filteredProducts = products.where((doc) {
                    final name = doc['cropName'].toString().toLowerCase();
                    return name.contains(searchQuery.toLowerCase());
                  }).toList();

                  if (filteredProducts.isEmpty) {
                    return const Center(child: Text("No products found."));
                  }

                  return ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final doc = filteredProducts[index];
                      final freshness = getFreshnessStatus(doc['harvestDate']);
                      final base64Image = doc['image'];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: base64Image != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              base64Decode(base64Image),
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                          )
                              : const Icon(Icons.image, size: 40),

                          title: Text(doc['cropName']),
                          subtitle: Text(
                            "Price: ₹${doc['demandPrice']} | Qty: ${doc['quantity']}kg",
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(freshness, style: TextStyle(color: getFreshnessColor(freshness))),
                              const SizedBox(height: 4),
                              Text(DateFormat.yMMMd().format(doc['harvestDate'].toDate()),
                                  style: const TextStyle(fontSize: 10)),
                            ],
                          ),
                          onTap: () {
                            // Open details page if needed later
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Freshness status helper methods
  String getFreshnessStatus(Timestamp harvestDate) {
    final now = DateTime.now();
    final days = now.difference(harvestDate.toDate()).inDays;

    if (days <= 2) return 'Fresh';
    if (days <= 5) return 'Okay';
    return 'Old';
  }

  Color getFreshnessColor(String status) {
    switch (status) {
      case 'Fresh':
        return Colors.green;
      case 'Okay':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }
}

