class Order {
  final String productId;
  final String productName;
  final String farmerId;
  final String farmerName;
  final String customerId;
  final String customerName;
  final int quantity;
  final double bidPrice;
  final String status;
  final DateTime timestamp;

  Order({
    required this.productId,
    required this.productName,
    required this.farmerId,
    required this.farmerName,
    required this.customerId,
    required this.customerName,
    required this.quantity,
    required this.bidPrice,
    this.status = "Pending",
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'customerId': customerId,
      'customerName': customerName,
      'quantity': quantity,
      'bidPrice': bidPrice,
      'status': status,
      'timestamp': timestamp,
    };
  }
}
