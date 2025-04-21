import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartPage extends StatelessWidget {
  final String customerId = 'uid2'; // Placeholder customer UID

  CartPage({super.key});

  void showInvoice(BuildContext context, List<QueryDocumentSnapshot> cartItems) {
    double itemTotal = 0;
    const double deliveryFee = 20;

    for (var item in cartItems) {
      final data = item.data() as Map<String, dynamic>;
      itemTotal += (data['price'] ?? 0) * (data['quantity'] ?? 1);
    }

    double totalAmount = itemTotal + deliveryFee;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Invoice Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Item Total"),
                  Text("₹${itemTotal.toStringAsFixed(2)}"),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Delivery Fee"),
                  Text("₹${deliveryFee.toStringAsFixed(2)}"),
                ],
              ),
              const Divider(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("₹${totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Confirm & Place Order"),
                  onPressed: () async {
                    Navigator.pop(context); // Close invoice
                    await placeOrder(context, cartItems);
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> placeOrder(BuildContext context, List<QueryDocumentSnapshot> cartItems) async {
    final batch = FirebaseFirestore.instance.batch();

    final ordersRef = FirebaseFirestore.instance.collection('orders');
    final cartRef = FirebaseFirestore.instance.collection('cart');

    for (var item in cartItems) {
      final data = item.data() as Map<String, dynamic>;
      batch.set(ordersRef.doc(), {
        'customerId': customerId,
        'productId': data['productId'],
        'productName': data['productName'],
        'price': data['price'],
        'quantity': data['quantity'],
        'timestamp': Timestamp.now(),
      });

      // Remove from cart
      batch.delete(cartRef.doc(item.id));
    }

    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Order placed successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .where('customerId', isEqualTo: customerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final cartItems = snapshot.data!.docs;

          if (cartItems.isEmpty) {
            return const Center(child: Text("Your cart is empty."));
          }

          double totalAmount = 0;
          for (var item in cartItems) {
            final data = item.data() as Map<String, dynamic>;
            totalAmount += (data['price'] ?? 0) * (data['quantity'] ?? 1);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final data = cartItems[index].data() as Map<String, dynamic>;
                    final cartId = cartItems[index].id;

                    final productName = data['productName'] ?? '';
                    final quantity = data['quantity'] ?? 1;
                    final price = data['price'] ?? 0;
                    final total = price * quantity;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('₹$price × $quantity = ₹$total'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            FirebaseFirestore.instance.collection('cart').doc(cartId).delete();
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text("Total: ₹${totalAmount.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () => showInvoice(context, cartItems),
                        child: const Text("Checkout", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
