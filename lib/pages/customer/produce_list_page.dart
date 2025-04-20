import 'package:flutter/material.dart';

class ProduceListPage extends StatelessWidget {
  final String productName;

  const ProduceListPage({super.key, required this.productName});

  @override
  Widget build(BuildContext context) {
    // Temporary mock produce listings
    final List<Map<String, String>> produceList = [
      {'farmer': 'Farmer A', 'price': '₹40/kg', 'location': '2 km away'},
      {'farmer': 'Farmer B', 'price': '₹35/kg', 'location': '3.5 km away'},
      {'farmer': 'Farmer C', 'price': '₹42/kg', 'location': '1.2 km away'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('$productName Listings'),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: produceList.length,
        itemBuilder: (context, index) {
          final produce = produceList[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(Icons.agriculture, color: Colors.green),
              title: Text(produce['farmer']!),
              subtitle: Text('${produce['price']} • ${produce['location']}'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // You can navigate to Bargain screen or Product detail here
              },
            ),
          );
        },
      ),
    );
  }
}
