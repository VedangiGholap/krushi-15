import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_product.dart';

class InventoryPage extends StatelessWidget {
  final String farmerId;

  const InventoryPage({super.key, required this.farmerId});

  @override
  Widget build(BuildContext context) {
    final inventoryRef = FirebaseFirestore.instance.collection('inventory');
    final ordersRef = FirebaseFirestore.instance.collection('orders');

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Inventory"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: inventoryRef.where('farmerId', isEqualTo: farmerId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading data."));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No items in inventory.\nTap + to add.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          docs.sort((a, b) {
            final aTime = a['timestamp'] as Timestamp?;
            final bTime = b['timestamp'] as Timestamp?;
            return (bTime?.millisecondsSinceEpoch ?? 0)
                .compareTo(aTime?.millisecondsSinceEpoch ?? 0);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final productId = docs[index].id;
              final imageUrl = data['imageUrl'] ?? '';
              final productName = data['productName'] ?? 'Unnamed';
              final quantity = data['quantity'] ?? 0;
              final unit = data['unit'] ?? '';
              final price = data['price'] ?? 0;

              return GestureDetector(
                onTap: () {
                  // Navigate to filtered orders page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FilteredOrdersPage(
                        productId: productId,
                        productName: productName,
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: imageUrl.isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                        ),
                      )
                          : const Icon(Icons.image_not_supported),
                      title: Text(
                        productName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '$quantity $unit remaining • ₹$price per $unit',
                        style:
                        const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddInventoryItemPage(farmerId: farmerId),
            ),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Placeholder for filtered orders page
class FilteredOrdersPage extends StatelessWidget {
  final String productId;
  final String productName;

  const FilteredOrdersPage({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  Widget build(BuildContext context) {
    final ordersRef = FirebaseFirestore.instance.collection('orders');

    return Scaffold(
      appBar: AppBar(
        title: Text("Orders for $productName"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersRef.where('productId', isEqualTo: productId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data?.docs ?? [];

          if (orders.isEmpty) {
            return const Center(
              child: Text("No orders for this product."),
            );
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final data = orders[index].data() as Map<String, dynamic>;
              final quantity = data['quantityOrdered'] ?? 0;
              final status = data['status'] ?? 'Pending';
              final customer = data['customerId'] ?? 'Unknown';

              return ListTile(
                title: Text("Qty: $quantity • Status: $status"),
                subtitle: Text("Customer: $customer"),
              );
            },
          );
        },
      ),
    );
  }
}
