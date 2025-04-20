import 'package:flutter/material.dart';
import 'farmer_inventory.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';


class AddProductPage extends StatefulWidget {
  final String farmerId;
  const AddProductPage({super.key, required this.farmerId});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final quantityController = TextEditingController();
  final priceController = TextEditingController();

  String selectedCategory = '';
  String? selectedVariety;
  int quantity = 0;
  double maxPrice = 0.0;
  double demandPrice = 0.0;
  DateTime? harvestDate;
  File? imageFile;
  bool uploading = false;
  bool availableToBargain = false;

  final Map<String, List<String>> categoryMap = {
    'Vegetables': ['Tomato', 'Ladyfinger', 'Spinach'],
    'Fruits': ['Banana', 'Strawberry'],
    'Grains': ['Rice', 'Wheat'],
  };

  @override
  void initState() {
    super.initState();
    harvestDate = DateTime.now();
    selectedCategory = '';
  }

  @override
  void dispose() {
    quantityController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> captureImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> pickHarvestDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: harvestDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => harvestDate = picked);
  }

  Future<void> uploadProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (imageFile == null) {
      showError("Please capture an image.");
      return;
    }
    if (harvestDate == null) {
      showError("Please select harvest date.");
      return;
    }

    setState(() => uploading = true);

    try {
      quantity = int.tryParse(quantityController.text) ?? 0;
      maxPrice = double.tryParse(priceController.text) ?? 0.0;
      demandPrice = maxPrice * 0.8;

      //  Upload image to Firebase Storage
      final fileName = 'product_${const Uuid().v4()}.jpg';
      final ref = FirebaseStorage.instance.ref().child('product_images').child(fileName);
      await ref.putFile(imageFile!);
      final imageUrl = await ref.getDownloadURL();

      //  Upload to Firestore
      await FirebaseFirestore.instance.collection('inventory').add({
        'farmerId': widget.farmerId,
        'cropName': selectedCategory,
        'variety': selectedVariety,
        'quantity': quantity,
        'quantityRemaining': quantity,
        'maxPrice': maxPrice,
        'demandPrice': demandPrice,
        'harvestDate': Timestamp.fromDate(harvestDate!),
        'image': imageUrl, // <-- store URL instead of base64
        'availableToBargain': availableToBargain,
        'uploadedAt': Timestamp.now(),
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => InventoryPage(farmerId: widget.farmerId)),
      );
    } catch (e) {
      setState(() => uploading = false);
      showError('Upload failed: ${e.toString()}');
    }
  }


  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
      ),
      body: uploading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: captureImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: imageFile != null
                      ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(imageFile!, fit: BoxFit.cover))
                      : const Center(
                    child: Icon(Icons.camera_alt, size: 40, color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                hint: const Text("Select Category"),
                value: selectedCategory.isNotEmpty ? selectedCategory : null,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                items: categoryMap.keys
                    .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                    selectedVariety = categoryMap[selectedCategory]!.first;
                  });
                },
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                hint: const Text("Select Variety"),
                value: selectedVariety,
                decoration: const InputDecoration(labelText: 'Variety', border: OutlineInputBorder()),
                items: selectedCategory.isEmpty
                    ? []
                    : categoryMap[selectedCategory]!
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (value) => setState(() => selectedVariety = value),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity (kg)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Max Price per kg (₹)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: pickHarvestDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        harvestDate != null
                            ? DateFormat.yMMMMd().format(harvestDate!)
                            : 'Select Harvest Date',
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Available to Bargain'),
                  Switch(
                    value: availableToBargain,
                    onChanged: (val) => setState(() => availableToBargain = val),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text("Upload Product", style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: uploadProduct,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

