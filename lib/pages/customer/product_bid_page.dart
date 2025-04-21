import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:krushi_version16/services/pricing_service.dart';

class ProductBidPage extends StatefulWidget {
  final String inventoryId;

  const ProductBidPage({super.key, required this.inventoryId});

  @override
  State<ProductBidPage> createState() => _ProductBidPageState();
}

class _ProductBidPageState extends State<ProductBidPage> {
  double? suggestedPrice;
  double? customerBid;
  int quantity = 1;
  double? cp;
  double? msp;
  double? dynamicAdjustment;
  bool? offerAccepted;
  bool isLoading = true;

  String? productName;
  String? farmerName;
  String? farmerLocation;

  final TextEditingController _bidController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchInventoryData();
  }

  Future<void> fetchInventoryData() async {
    final doc = await FirebaseFirestore.instance
        .collection('inventory')
        .doc(widget.inventoryId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        suggestedPrice = (data['suggestedPrice'] as num).toDouble();
        cp = (data['costOfProduction'] as num).toDouble();
        msp = (data['msp'] as num).toDouble();

        productName = data['productName'];
        farmerName = data['farmerName'];
        farmerLocation = data['farmerLocation'];

        final harvestDate = (data['harvestDate'] as Timestamp).toDate();
        final age = DateTime.now().difference(harvestDate).inDays;
        final stockLevel = (data['stockLevel'] as num).toDouble();

        dynamicAdjustment = PricingService.calculateDynamicPrice(
          age: age,
          stockLevel: stockLevel,
          cp: cp!,
          msp: msp!,
        );

        isLoading = false;
      });
    }
  }

  void _submitBid() {
    final enteredBid = double.tryParse(_bidController.text.trim());
    if (enteredBid == null) return;

    final accepted = PricingService.shouldAcceptBid(
      customerBid: enteredBid,
      cp: cp!,
      msp: msp!,
      dynamicPrice: dynamicAdjustment!,
    );

    setState(() {
      customerBid = enteredBid;
      offerAccepted = accepted;
    });
  }

  Future<void> _confirmOrder() async {
    final totalPrice = customerBid! * quantity;

    await FirebaseFirestore.instance.collection('orders').add({
      'inventoryId': widget.inventoryId,
      'productName': productName,
      'farmerName': farmerName,
      'farmerLocation': farmerLocation,
      'quantity': quantity,
      'unitPrice': customerBid,
      'totalPrice': totalPrice,
      'status': 'Pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Order placed successfully')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final total = customerBid != null ? (customerBid! * quantity) : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text("Place a Bid"), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Recommended Price: ₹${suggestedPrice!.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 20),

            TextFormField(
              controller: _bidController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Your Offer (₹)"),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                const Text("Quantity: "),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
                ),
                Text('$quantity', style: const TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => quantity++),
                ),
              ],
            ),

            Text(
              "Total Price: ₹${total.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text("Place Offer"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: _submitBid,
            ),

            const SizedBox(height: 30),

            if (offerAccepted != null)
              Column(
                children: [
                  Text(
                    offerAccepted! ? "🎉 Offer Accepted!" : "❌ Offer Rejected",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: offerAccepted! ? Colors.green : Colors.red,
                    ),
                  ),
                  if (offerAccepted! && customerBid != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text("Confirm Order"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: _confirmOrder,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}