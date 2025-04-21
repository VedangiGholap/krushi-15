import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CustomerOrdersPage extends StatelessWidget {
  final String customerId = 'uid2'; // Replace with dynamic customer UID if needed

  CustomerOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Directly fetch orders for the current customer without using complex queries
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('customerId', isEqualTo: customerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(child: Text("You haven't placed any orders yet."));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final data = orders[index].data() as Map<String, dynamic>;
              final productName = data['productName'] ?? '';
              final quantity = data['quantity'] ?? 0;
              final price = data['price'] ?? 0;
              final total = price * quantity;
              final timestamp = data['timestamp'] as Timestamp;
              final status = data['status'] ?? 'Pending'; // Default to 'Pending'

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('₹$price × $quantity = ₹$total'),
                      Text('Ordered on: ${DateFormat.yMMMd().add_jm().format(timestamp.toDate())}'),
                      Text(
                        'Status: $status',
                        style: TextStyle(
                          color: status == 'Delivered'
                              ? Colors.green
                              : (status == 'Pending'
                              ? Colors.orange
                              : Colors.blue),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  leading: const Icon(Icons.shopping_bag, color: Colors.green),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
