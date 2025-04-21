import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_detail.dart';

class ProduceListPage extends StatelessWidget {
  final String productName;

  const ProduceListPage({super.key, required this.productName});

  Future<Map<String, dynamic>?> fetchFarmerData(String farmerId) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(farmerId).get();
    return doc.exists ? doc.data() : null;
  }

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
              final farmerId = data['farmerId'] ?? '';

              return FutureBuilder<Map<String, dynamic>?>(
                future: fetchFarmerData(farmerId),
                builder: (context, farmerSnapshot) {
                  if (farmerSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text("Loading farmer..."),
                      subtitle: Text("Please wait"),
                      leading: CircularProgressIndicator(),
                    );
                  }

                  final farmerData = farmerSnapshot.data;
                  final farmerName = farmerData?['name'] ?? 'Unknown Farmer';
                  final farmerLocation = farmerData?['location'] ?? 'Unknown Location';

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.agriculture, color: Colors.green, size: 30),
                      title: Text(
                        farmerName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('₹$price/$unit • $farmerLocation'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailPage(
                              productData: data,
                              farmerData: farmerData ?? {},
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
