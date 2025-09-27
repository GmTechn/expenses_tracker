import 'dart:io';
import 'package:expenses_tracker/components/mybutton.dart';
import 'package:expenses_tracker/components/mynavbar.dart';
import 'package:expenses_tracker/components/mytextfield.dart';
import 'package:expenses_tracker/management/database.dart';
import 'package:expenses_tracker/models/users.dart';
import 'package:expenses_tracker/pages/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ProfilePage extends StatefulWidget {
  final String email;
  const ProfilePage({super.key, required this.email});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Text controllers
  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _imageFile;
  String? _photoPath;
  AppUser? _user;

  final _picker = ImagePicker();
  final DatabaseManager _databaseManager = DatabaseManager();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fnameController.dispose();
    _lnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    await _databaseManager.initialisation();
    AppUser? user = await _databaseManager.getUserByEmail(widget.email);

    if (!mounted) return;

    if (user != null) {
      _user = user;
      _fnameController.text = user.fname ?? '';
      _lnameController.text = user.lname ?? '';
      _emailController.text = user.email ?? widget.email;
      _phoneController.text = user.phone ?? '';
      if (user.photoPath != null && user.photoPath!.isNotEmpty) {
        final f = File(user.photoPath!);
        if (f.existsSync()) {
          _imageFile = f;
          _photoPath = user.photoPath;
        }
      }
    }

    setState(() => _isLoading = false);
  }

  // Pick image and copy to app directory
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 70);
      if (picked != null) {
        // Get app document directory
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = path.basename(picked.path);
        final savedImage =
            await File(picked.path).copy('${appDir.path}/$fileName');

        setState(() {
          _imageFile = savedImage;
          _photoPath = savedImage.path;
        });

        if (_user != null) {
          final updated = _user!.copyWith(photoPath: _photoPath);
          await _databaseManager.upsertAppUser(updated);
          _user = updated;
        }
      }
    } catch (e) {
      debugPrint('Image pick error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image')),
        );
      }
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
              },
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.photo),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFullImage() {
    if (_imageFile == null) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: Image.file(_imageFile!),
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (_user == null) return;

    final updated = AppUser(
      id: _user!.id,
      fname: _fnameController.text.trim(),
      lname: _lnameController.text.trim(),
      email: _emailController.text.trim(),
      password: _user!.password,
      phone: _phoneController.text.trim(),
      photoPath: _photoPath ?? '',
    );

    try {
      await _databaseManager.upsertAppUser(updated);
      _user = updated;
      await _loadProfile();

      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Your changes have been saved.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Update failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    }
  }

  Future<void> _confirmCancel() async {
    final doCancel = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Are you sure you want to discard your edits?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (doCancel == true) await _loadProfile();
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage(email: '')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff181a1e),
      appBar: AppBar(
        backgroundColor: const Color(0xff181a1e),
        automaticallyImplyLeading: false,
        title: const Text(
          'P R O F I L E',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.power, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xff050c20)))
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: _showFullImage,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!)
                                : null,
                            child: _imageFile == null
                                ? const Icon(
                                    CupertinoIcons.person_crop_circle_fill,
                                    size: 80,
                                    color: Colors.white)
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _showImagePickerOptions,
                            child: const CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white,
                              child: Icon(CupertinoIcons.camera_fill,
                                  color: Color(0xff050c20)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    MyTextFormField(
                      controller: _fnameController,
                      hintText: 'First Name',
                      obscureText: false,
                      leadingIcon: const Icon(CupertinoIcons.person_fill),
                    ),
                    const SizedBox(height: 20),
                    MyTextFormField(
                      controller: _lnameController,
                      hintText: 'Last Name',
                      obscureText: false,
                      leadingIcon: const Icon(CupertinoIcons.person_fill),
                    ),
                    const SizedBox(height: 20),
                    MyTextFormField(
                      controller: _emailController,
                      hintText: 'Email',
                      obscureText: false,
                      leadingIcon: const Icon(CupertinoIcons.mail_solid),
                    ),
                    const SizedBox(height: 20),
                    MyTextFormField(
                      controller: _phoneController,
                      hintText: 'Phone Number',
                      obscureText: false,
                      leadingIcon: const Icon(CupertinoIcons.phone_fill),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        MyButton(
                          textbutton: 'Update',
                          onTap: _updateProfile,
                          buttonHeight: 40,
                          buttonWidth: 100,
                        ),
                        const SizedBox(width: 40),
                        MyButton(
                          textbutton: 'Cancel',
                          onTap: _confirmCancel,
                          buttonHeight: 40,
                          buttonWidth: 100,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: MyNavBar(currentIndex: 3, email: widget.email),
    );
  }
}
