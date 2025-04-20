import 'package:flutter/material.dart';
import 'product.dart'; // import your model

class ProductListPage extends StatefulWidget {
  final String category;
  final String productName;

  const ProductListPage({
    Key? key,
    required this.category,
    required this.productName,
  }) : super(key: key);

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Product> productList = [];

  @override
  void initState() {
    super.initState();
    fetchProducts(); // temporary local fetch
  }

  void fetchProducts() async {
    // TEMPORARY LOCAL DATA
    List<Map<String, dynamic>> rawData = [
      {
        'category': 'Vegetables',
        'name': 'Tomatoes',
        'imageUrl': 'https://via.placeholder.com/150',
        'price': '₹20/kg',
        'farmerName': 'Farmer A',
      },
      {
        'category': 'Vegetables',
        'name': 'Tomatoes',
        'imageUrl': 'https://via.placeholder.com/150',
        'price': '₹22/kg',
        'farmerName': 'Farmer B',
      },
      {
        'category': 'Fruits',
        'name': 'Bananas',
        'imageUrl': 'https://via.placeholder.com/150',
        'price': '₹30/dozen',
        'farmerName': 'Farmer C',
      },
    ];

    final filtered = rawData
        .where((item) =>
    item['category'] == widget.category &&
        item['name'] == widget.productName)
        .map((item) => Product.fromMap(item))
        .toList();

    setState(() {
      productList = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.productName} Listings')),
      body: productList.isEmpty
          ? Center(child: Text("No listings found"))
          : ListView.builder(
        itemCount: productList.length,
        itemBuilder: (context, index) {
          final product = productList[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: Image.network(product.imageUrl, width: 60, height: 60),
              title: Text(product.farmerName),
              subtitle: Text(product.price),
            ),
          );
        },
      ),
    );
  }
}
