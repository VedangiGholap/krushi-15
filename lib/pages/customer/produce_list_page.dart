import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProduceListPage extends StatelessWidget {
  final String productName;

  const ProduceListPage({super.key, required this.productName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$productName Listings'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('inventory')
            .where('productName', isEqualTo: productName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No listings available for this product."),
            );
          }

          final produceList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: produceList.length,
            itemBuilder: (context, index) {
              final data = produceList[index].data() as Map<String, dynamic>;
              final price = data['price'] ?? 0;
              final unit = data['unit'] ?? 'kg';
              final farmerName = data['farmerName'] ?? 'Unknown Farmer';
              final location = data['location'] ?? 'Unknown Location';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.agriculture, color: Colors.green),
                  title: Text(farmerName),
                  subtitle: Text('₹$price/$unit • $location'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigate to detailed produce info or bargain screen
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
