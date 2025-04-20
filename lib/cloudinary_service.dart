import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'dart:convert';

Future<String?> uploadImageToCloudinary(File imageFile) async {
  const cloudName = 'dwzy2hmz2';  // Replace with your Cloudinary cloud name
  const uploadPreset = 'farm_upload';  // Replace with your Cloudinary upload preset

  final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

  final mimeType = lookupMimeType(imageFile.path)!.split('/');
  print("Uploading image with mime type: $mimeType");

  try {
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: MediaType(mimeType[0], mimeType[1]),
          filename: basename(imageFile.path),
        ),
      );

    final response = await request.send();

    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final responseData = json.decode(resStr);

      print("Cloudinary upload success: ${responseData['secure_url']}");
      return responseData['secure_url']; // Return the secure URL
    } else {
      // Print the full response to check for errors
      final resStr = await response.stream.bytesToString();
      print("Upload failed with status code: ${response.statusCode}");
      print("Response body: $resStr");
      return null;
    }
  } catch (e) {
    print("Error uploading image to Cloudinary: $e");
    return null;
  }
}

