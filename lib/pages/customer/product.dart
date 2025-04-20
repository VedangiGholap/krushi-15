class Product {
  final String category;
  final String name;
  final String imageUrl;
  final String price;
  final String farmerName;

  Product({
    required this.category,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.farmerName,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      category: map['category'],
      name: map['name'],
      imageUrl: map['imageUrl'],
      price: map['price'],
      farmerName: map['farmerName'],
    );
  }
}
