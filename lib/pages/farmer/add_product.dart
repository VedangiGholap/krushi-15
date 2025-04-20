import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
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

  File? _imageFile;
  bool _isUploading = false;

  late TextEditingController _categoryController;

  final units = ['kg', 'dozen', 'litre'];
  final picker = ImagePicker();

  // Predefined product-category mapping based on customer home
  final Map<String, String> productCategoryMap = {
    'Tomatoes': 'Vegetables',
    'Spinach': 'Vegetables',
    'LadyFinger': 'Vegetables',
    'Bananas': 'Fruits',
    'Strawberries': 'Fruits',
    'Rice': 'Grains',
    'Wheat': 'Grains',
  };

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
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
      String? imageUrl = await uploadImageToCloudinary(_imageFile!);
      if (imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image upload failed')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('inventory').add({
        'productName': productName,
        'category': category,
        'quantity': quantity,
        'unit': unit,
        'price': price,
        'imageUrl': imageUrl,
        'farmerId': widget.farmerId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
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
                  color: Colors.green[100],
                  child: const Icon(Icons.add_a_photo, size: 50),
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(8),
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
                items: productCategoryMap.keys.map((product) {
                  return DropdownMenuItem(
                    value: product,
                    child: Text(product),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    productName = value;
                    category = productCategoryMap[value];
                    _categoryController.text = category ?? '';
                  });
                },
                validator: (val) => val == null ? 'Select a product' : null,
                value: productName,
              ),

              const SizedBox(height: 12),

              // Auto-filled category field
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),

              const SizedBox(height: 12),

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
                      items: units
                          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (val) => setState(() => unit = val!),
                      decoration: const InputDecoration(labelText: 'Unit'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price per unit (₹)'),
                onSaved: (val) => price = double.tryParse(val!),
                validator: (val) => val!.isEmpty ? 'Enter price' : null,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _isUploading
                      ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.upload),
                  label: Text(_isUploading ? 'Uploading...' : 'Add to Inventory'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  onPressed: _isUploading ? null : _submitForm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
