import 'package:flutter/material.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> productData;
  final Map<String, dynamic>? farmerData;

  const ProductDetailPage({
    super.key,
    required this.productData,
    required this.farmerData,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final TextEditingController bidController = TextEditingController();
  String bargainResult = '';

  String autoBargainDecision({
    required double priceSetByFarmer,
    required double costOfProduction,
    double? msp,
    required double customerBid,
  }) {
    final m = msp != null ? (costOfProduction < msp ? costOfProduction : msp) : costOfProduction;
    final sp = (msp != null ? (costOfProduction > msp ? costOfProduction : msp) : costOfProduction) + 5;

    if (customerBid >= sp) {
      return 'Offer Accepted 🎉';
    } else if (customerBid >= m) {
      return 'Counter Offer: You\'re close 🤝';
    } else {
      return 'Offer Rejected ❌';
    }
  }

  void handleMakeOffer() {
    final bid = double.tryParse(bidController.text);
    if (bid == null) return;

    final product = widget.productData;
    final double price = product['price']?.toDouble() ?? 0;
    final double costOfProduction = product['costOfProduction']?.toDouble() ?? 0;
    final double? msp = product['msp'] != null ? product['msp'].toDouble() : null;

    final result = autoBargainDecision(
      priceSetByFarmer: price,
      costOfProduction: costOfProduction,
      msp: msp,
      customerBid: bid,
    );

    setState(() => bargainResult = result);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.productData;
    final imageUrl = product['imageUrl'] ?? '';
    final productName = product['productName'];
    final price = product['price'];
    final unit = product['unit'];
    final quantity = product['quantity'];
    final flexible = product['flexible'] ?? false;

    final farmerName = widget.farmerData?['name'] ?? 'Unknown';
    final farmerLocation = widget.farmerData?['location'] ?? 'Unknown';

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

            if (flexible) ...[
              const Text(
                'This item is available for bargaining.',
                style: TextStyle(fontWeight: FontWeight.w500, color: Colors.orange),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      double current = double.tryParse(bidController.text) ?? 0;
                      if (current > 0) {
                        bidController.text = (current - 10).toStringAsFixed(0);
                      }
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: bidController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Your Offer Price (₹)',
                        border: OutlineInputBorder(),
                        prefixText: '₹ ',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      double current = double.tryParse(bidController.text) ?? 0;
                      bidController.text = (current + 10).toStringAsFixed(0);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                icon: const Icon(Icons.local_offer),
                label: const Text('Make Offer'),
                onPressed: handleMakeOffer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 12),
              if (bargainResult.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text(
                    bargainResult,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              const SizedBox(height: 20),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
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
