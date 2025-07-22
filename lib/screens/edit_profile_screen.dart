import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final _nameController = TextEditingController();
  String? _email;
  String? _photoUrl;
  File? _pickedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (currentUser == null) return;
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .get();
    final data = doc.data();
    setState(() {
      _nameController.text = data?['displayName'] ?? '';
      _email = data?['email'] ?? currentUser!.email;
      _photoUrl = data?['photoUrl'] ?? '';
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
      // TODO: Upload image to storage and update Firestore photoUrl
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pics')
          .child(
            '${currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
      final uploadTask = await ref.putFile(image);
      final url = await uploadTask.ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Image upload error: $e');
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (currentUser == null) return;
    setState(() => _isLoading = true);
    String? photoUrl = _photoUrl;
    if (_pickedImage != null) {
      final uploadedUrl = await _uploadImage(_pickedImage!);
      if (uploadedUrl != null) {
        photoUrl = uploadedUrl;
      }
    }
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .set({
          'displayName': _nameController.text.trim(),
          'photoUrl': photoUrl ?? '',
        }, SetOptions(merge: true));
    setState(() => _isLoading = false);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF111B21),
        elevation: 1,
      ),
      backgroundColor: const Color(0xFF181F25),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 54,
                            backgroundColor: Colors.grey[300],
                            backgroundImage:
                                _pickedImage != null
                                    ? FileImage(_pickedImage!)
                                    : (_photoUrl != null &&
                                        _photoUrl!.isNotEmpty)
                                    ? NetworkImage(_photoUrl!) as ImageProvider
                                    : null,
                            child:
                                (_photoUrl == null || _photoUrl!.isEmpty) &&
                                        _pickedImage == null
                                    ? const Icon(
                                      Icons.person,
                                      size: 54,
                                      color: Colors.white70,
                                    )
                                    : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: const Color(0xFF202C33),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: TextEditingController(text: _email ?? ''),
                      enabled: false,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: const Color(0xFF202C33),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  'Save',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
