import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FarmerOrdersPage extends StatelessWidget {
  final String farmerId = 'uid1'; // Replace with actual farmer UID

  FarmerOrdersPage({super.key});

  final List<String> statusOptions = ['Pending', 'Accepted', 'Out for Delivery', 'Delivered'];

  void updateOrderStatus(String orderId, String newStatus) {
    FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': newStatus,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Farmer Orders"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('farmerId', isEqualTo: farmerId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(child: Text("No orders received yet."));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];
              final data = doc.data() as Map<String, dynamic>;

              final productName = data['productName'] ?? '';
              final quantity = data['quantity'] ?? 0;
              final price = data['price'] ?? 0;
              final total = price * quantity;
              final status = data['status'] ?? 'Pending';
              final timestamp = data['timestamp'] as Timestamp;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.shopping_cart, color: Colors.green),
                  title: Text(productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('₹$price × $quantity = ₹$total'),
                      Text('Ordered on: ${DateFormat.yMMMd().add_jm().format(timestamp.toDate())}'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text("Status: "),
                          DropdownButton<String>(
                            value: status,
                            items: statusOptions.map((String option) {
                              return DropdownMenuItem<String>(
                                value: option,
                                child: Text(option),
                              );
                            }).toList(),
                            onChanged: (newStatus) {
                              if (newStatus != null) {
                                updateOrderStatus(doc.id, newStatus);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
