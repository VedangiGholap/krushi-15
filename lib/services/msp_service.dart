import 'package:cloud_firestore/cloud_firestore.dart';

class MspService {
  Future<double> fetchMSP(String productName) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('msp')
          .doc(productName) // This uses the product name as the document ID
          .get();

      if (docSnapshot.exists) {
        // Make sure the msp field is fetched as a double
        var mspValue = docSnapshot.data()?['msp'];

        // Check if mspValue is of type double, if not convert it to double
        if (mspValue is int) {
          return mspValue.toDouble();  // Convert int to double
        } else if (mspValue is double) {
          return mspValue;  // If it's already a double, return it
        } else {
          return 0.0;  // Return 0.0 if MSP is not a valid type
        }
      } else {
        throw 'MSP not found for product: $productName';  // Custom error message
      }
    } catch (e) {
      print('Error fetching MSP: $e');  // Log the error
      return 0.0;  // Fallback to 0.0 if there's an error
    }
  }
}
