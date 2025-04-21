import 'package:flutter/material.dart';


class ProductDetailPage extends StatelessWidget {

  final Map<String, dynamic> productData;
  final Map<String, dynamic>? farmerData;

  const ProductDetailPage({
    super.key,
    required this.productData,
    required this.farmerData,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = productData['imageUrl'] ?? '';
    final productName = productData['productName'];
    final price = productData['price'];
    final unit = productData['unit'];
    final quantity = productData['quantity'];
    final flexible = productData['flexible'] ?? false;

    final farmerName = farmerData?['name'] ?? 'Unknown';
    final farmerLocation = farmerData?['location'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: Text(productName),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imageUrl),
              ),
            const SizedBox(height: 16),
            Text(
              '$productName - ₹$price/$unit',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Available Quantity: $quantity $unit'),
            const SizedBox(height: 8),
            Text('Farmer: $farmerName'),
            Text('Location: $farmerLocation'),
            const SizedBox(height: 16),
            if (flexible)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This item is available for bargaining.',
                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.orange),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Your Offer Price (₹)',
                      border: OutlineInputBorder(),
                      prefixText: '₹ ',
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Handle add to cart logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item added to cart!')),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add to Cart'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
