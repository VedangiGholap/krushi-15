import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class MspService {
  // Function to fetch MSP for a given product name
  Future<double> fetchMSP(String productName) async {
    try {
      // Replace the URL with the actual website for fetching MSP
      final url = 'https://www.commodityonline.com//msp/$productName'; // Replace with the actual URL
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parse the HTML content from the response
        var document = parser.parse(response.body);

        // Replace the selector with the correct one based on the website structure
        final mspElement = document.querySelector('selector-for-msp'); // Adjust this selector as needed

        if (mspElement != null) {
          // Convert the text of the element to a double and return it
          final msp = double.tryParse(mspElement.text.trim());
          return msp ?? 0.0; // If MSP is not found, return 0.0
        } else {
          return 0.0; // Return 0.0 if MSP is not found
        }
      } else {
        // Handle the case when the request fails (e.g., 404 or network issue)
        throw Exception('Failed to fetch MSP data');
      }
    } catch (e) {
      print('Error fetching MSP: $e');
      return 0.0; // Return 0.0 if there is an error fetching the data
    }
  }
}
