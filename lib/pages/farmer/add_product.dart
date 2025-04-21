import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:krushi_version16/cloudinary_service.dart';

class AddInventoryItemPage extends StatefulWidget {
  final String farmerId;

  const AddInventoryItemPage({super.key, required this.farmerId});

  @override
  State<AddInventoryItemPage> createState() => _AddInventoryItemPageState();
}

class _AddInventoryItemPageState extends State<AddInventoryItemPage> {
  final _formKey = GlobalKey<FormState>();

  String? productName;
  String? category;
  int? quantity;
  String unit = 'kg';
  double? price;
  bool flexible = false;
  bool bargainMode = false;  // Added bargain mode toggle

  File? _imageFile;
  bool _isUploading = false;

  String? farmerName;
  String? farmerLocation;

  double? costOfProduction;
  double? maxPrice;  // Changed from minPrice to maxPrice

  double? msp;  // Declare the MSP variable

  final units = ['kg', 'dozen', 'litre'];

  DateTime? harvestDate;
  double? suggestedPrice;

  @override
  void initState() {
    super.initState();
    fetchFarmerInfo();
  }

  Future<void> fetchFarmerInfo() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'farmer')
        .limit(1) // just get one farmer (first match)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      setState(() {
        farmerName = doc['name'];
        farmerLocation = doc['location'];
      });
    } else {
      debugPrint('No farmer found.');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _imageFile == null || productName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isUploading = true);

    try {
      // Only proceed with the dynamic pricing if the bargain mode is ON
      if (bargainMode) {
        // Calculate dynamic price based on maxPrice
        if (maxPrice != null && quantity != null) {
          final double effectiveMaxPrice = maxPrice!;

          final double thresholdPrice = effectiveMaxPrice * 0.95; // Example: 95% of maxPrice

          // Calculate dynamic pricing (suggested price)
          final ageInDays = DateTime.now().difference(harvestDate!).inDays;
          final dynamicAdjustment = 0.05; // Example dynamic price adjustment, can be calculated dynamically

          final double finalSuggestedPrice = effectiveMaxPrice - (dynamicAdjustment * effectiveMaxPrice);

          setState(() {
            suggestedPrice = finalSuggestedPrice;
          });

          // Upload the image to Cloudinary
          String? imageUrl = await uploadImageToCloudinary(_imageFile!);
          if (imageUrl == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image upload failed')),
            );
            return;
          }

          // Add data to Firestore
          await FirebaseFirestore.instance.collection('inventory').add({
            'productName': productName,
            'category': category,
            'quantity': quantity,
            'unit': unit,
            'price': finalSuggestedPrice, // Set the final suggested price
            'imageUrl': imageUrl,
            'flexible': flexible,
            'costOfProduction': costOfProduction,
            'msp': msp, // Set the MSP value
            'thresholdPrice': thresholdPrice,
            'maxPrice': effectiveMaxPrice, // The maximum price
            'harvestDate': harvestDate,
            'initialQuantity': quantity,
            'soldQuantity': 0,
            'suggestedPrice': suggestedPrice,
            'farmerId': widget.farmerId,
            'farmerName': farmerName,
            'farmerLocation': farmerLocation,
            'timestamp': FieldValue.serverTimestamp(),
          });

          Navigator.pop(context);
        } else {
          throw 'Max Price or Quantity is missing.';
        }
      } else {
        // When bargainMode is OFF, just use cost per unit
        final double unitPrice = price ?? 0;

        // Upload the image to Cloudinary
        String? imageUrl = await uploadImageToCloudinary(_imageFile!);
        if (imageUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image upload failed')),
          );
          return;
        }

        // Add data to Firestore
        await FirebaseFirestore.instance.collection('inventory').add({
          'productName': productName,
          'category': category,
          'quantity': quantity,
          'unit': unit,
          'price': unitPrice, // Use the price per unit
          'imageUrl': imageUrl,
          'flexible': flexible,
          'costOfProduction': costOfProduction,
          'msp': msp, // Set the MSP value
          'harvestDate': harvestDate,
          'initialQuantity': quantity,
          'soldQuantity': 0,
          'farmerId': widget.farmerId,
          'farmerName': farmerName,
          'farmerLocation': farmerLocation,
          'timestamp': FieldValue.serverTimestamp(),
        });

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Item to Inventory"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _imageFile == null
                    ? Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add_a_photo, size: 50),
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _imageFile!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Product Name Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  'Tomato', 'Spinach', 'Lady Finger', 'Banana', 'Strawberry', 'Rice', 'Wheat'
                ].map((product) {
                  return DropdownMenuItem(value: product, child: Text(product));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    productName = value;
                    category = value == 'Tomato' || value == 'Spinach' || value == 'Lady Finger' ? 'Vegetable' :
                    value == 'Banana' || value == 'Strawberry' ? 'Fruit' : 'Grain';
                  });
                },
                validator: (val) => val == null ? 'Select a product' : null,
                value: productName,
              ),
              const SizedBox(height: 12),

              // Category Display
              if (category != null)
                TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: category,
                ),
              const SizedBox(height: 12),

              // Quantity and Unit Input
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      onSaved: (val) => quantity = int.tryParse(val!),
                      validator: (val) => val!.isEmpty ? 'Enter quantity' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: unit,
                      items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (val) => setState(() => unit = val!),
                      decoration: const InputDecoration(labelText: 'Unit'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Bargain Toggle
              SwitchListTile(
                title: const Text("Bargain Mode"),
                value: bargainMode,
                onChanged: (val) {
                  setState(() {
                    bargainMode = val;
                  });
                },
              ),
              const SizedBox(height: 12),

              // Cost of Production, Max Price & MSP (if bargainMode is ON)
              if (bargainMode) ...[
                // Cost of Production
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Cost of Production (₹)'),
                  onSaved: (val) => costOfProduction = double.tryParse(val!),
                  validator: (val) => val!.isEmpty ? 'Enter cost of production' : null,
                ),
                const SizedBox(height: 12),
                // Max Price
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Maximum Price (₹)'),
                  onSaved: (val) => maxPrice = double.tryParse(val!),
                  validator: (val) => val!.isEmpty ? 'Enter maximum price' : null,
                ),
                const SizedBox(height: 12),
              ],

              // Submit Button
              ElevatedButton(
                onPressed: _isUploading ? null : _submitForm,
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
