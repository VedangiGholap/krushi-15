import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> productData;
  final Map<String, dynamic> farmerData;

  const ProductDetailPage({super.key, required this.productData, required this.farmerData});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1; // Default quantity

  @override
  Widget build(BuildContext context) {
    final product = widget.productData;
    final farmer = widget.farmerData;

    // Get the unit, price, image URL
    final unit = product['unit'] ?? 'kg';
    final price = product['price'] ?? 0;
    final imageUrl = product['imageUrl'] ?? ''; // Use imageUrl here

    return Scaffold(
      appBar: AppBar(
        title: Text('${product['productName']} Details'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                height: 200, // Adjust height as needed
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 16),

            // Farmer info
            Text(
              'Farmer: ${farmer['name'] ?? 'Unknown'}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Location: ${farmer['location'] ?? 'Unknown'}'),
            const SizedBox(height: 16),

            // Product info
            Text(
              'Price: ₹$price per $unit',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Unit: $unit'),
            const SizedBox(height: 16),

            // Quantity selection (Per Unit)
            Row(
              children: [
                const Text('Quantity: ', style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.red),
                  onPressed: () {
                    if (quantity > 1) {
                      setState(() {
                        quantity--;
                      });
                    }
                  },
                ),
                Text('$quantity $unit'),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.green),
                  onPressed: () {
                    setState(() {
                      quantity++;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Add to Cart button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  final customerId = 'uid2'; // Placeholder customer UID

                  // Add product to cart with selected quantity
                  FirebaseFirestore.instance.collection('cart').add({
                    'customerId': customerId,
                    'productId': product['id'],
                    'productName': product['productName'],
                    'price': price, // Use the price variable here
                    'quantity': quantity,
                    'timestamp': Timestamp.now(),
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product['productName']} x$quantity added to cart!')),
                  );
                },
                child: const Text("Add to Cart", style: TextStyle(fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



