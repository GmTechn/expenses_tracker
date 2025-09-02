import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:expenses_tracker/components/mybutton.dart';
import 'package:expenses_tracker/components/mynavbar.dart';
import 'package:expenses_tracker/components/mytextfield.dart';
import 'package:expenses_tracker/management/database.dart';
import 'package:expenses_tracker/models/users.dart';

class ProfilePage extends StatefulWidget {
  final String email;
  const ProfilePage({super.key, required this.email});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _imageFile;
  String? _photoPath;
  AppUser? _user;
  bool _isFullScreenImage = false;

  final _picker = ImagePicker();
  final DatabaseManager _databaseManager = DatabaseManager();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = await _databaseManager.getUserByEmail(widget.email);
    if (user != null) {
      setState(() {
        _user = user;
        _fnameController.text = user.fname;
        _lnameController.text = user.lname;
        _emailController.text = user.email;
        _phoneController.text = user.phone;
        _photoPath = user.photoPath;
        _imageFile = (_photoPath != null && _photoPath!.isNotEmpty)
            ? File(_photoPath!)
            : null;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _photoPath = picked.path;
      });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
        context: context,
        builder: (_) => SafeArea(
              child: Wrap(
                children: [
                  ListTile(
                      leading: const Icon(CupertinoIcons.photo_camera_solid),
                      title: const Text('Camera'),
                      onTap: () {
                        Navigator.of(context).pop();
                        _pickImage(ImageSource.camera);
                      }),
                  ListTile(
                      leading: const Icon(CupertinoIcons.photo),
                      title: const Text('Gallery'),
                      onTap: () {
                        Navigator.of(context).pop();
                        _pickImage(ImageSource.gallery);
                      }),
                ],
              ),
            ));
  }

  Future<void> _updateProfile() async {
    if (_user == null) return;

    final updatedUser = AppUser(
      id: _user!.id,
      fname: _fnameController.text.trim(),
      lname: _lnameController.text.trim(),
      email: _emailController.text.trim(),
      password: _user!.password,
      phone: _phoneController.text.trim(),
      photoPath: _photoPath ?? '',
    );

    await _databaseManager.updateAppUser(updatedUser);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );
  }

  void _toggleFullScreenImage() {
    setState(() {
      _isFullScreenImage = !_isFullScreenImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('P R O F I L E',
            style: TextStyle(color: Color(0xff050c20))),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: _toggleFullScreenImage,
                    child: CircleAvatar(
                      radius: _isFullScreenImage ? 120 : 60,
                      backgroundImage:
                          _imageFile != null ? FileImage(_imageFile!) : null,
                      child: _imageFile == null
                          ? const Icon(
                              CupertinoIcons.person_crop_circle_fill,
                              size: 80,
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showImagePickerOptions,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          CupertinoIcons.camera_fill,
                          color: Color(0xff050c20),
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Mytextfield(
                  controller: _fnameController,
                  hintText: 'First Name',
                  obscureText: false,
                  leadingIcon: const Icon(CupertinoIcons.person_fill)),
              const SizedBox(height: 20),
              Mytextfield(
                  controller: _lnameController,
                  hintText: 'Last Name',
                  obscureText: false,
                  leadingIcon: const Icon(CupertinoIcons.person_fill)),
              const SizedBox(height: 20),
              Mytextfield(
                  controller: _emailController,
                  hintText: 'Email',
                  obscureText: false,
                  leadingIcon: const Icon(CupertinoIcons.mail_solid)),
              const SizedBox(height: 20),
              Mytextfield(
                  controller: _phoneController,
                  hintText: 'Phone',
                  obscureText: false,
                  leadingIcon: const Icon(CupertinoIcons.phone_fill)),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyButton(
                      textbutton: 'Update',
                      onTap: _updateProfile,
                      buttonHeight: 40,
                      buttonWidth: 100),
                  const SizedBox(width: 40),
                  MyButton(
                      textbutton: 'Cancel',
                      onTap: () => _loadProfile(),
                      buttonHeight: 40,
                      buttonWidth: 100),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MyNavBar(currentIndex: 3, email: widget.email),
    );
  }
}
