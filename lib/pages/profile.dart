import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:expenses_tracker/components/mybutton.dart';
import 'package:expenses_tracker/components/mynavbar.dart';
import 'package:expenses_tracker/components/mytextfield.dart';
import 'package:expenses_tracker/pages/login.dart';
import 'package:expenses_tracker/models/users.dart';
import 'package:expenses_tracker/management/database.dart';

class ProfilePage extends StatefulWidget {
  final String email; // Email passed from login
  const ProfilePage({super.key, required this.email});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _phoneNumber = TextEditingController();
  String? _email;
  String? _photoPath;

  File? _imageFile;
  final picker = ImagePicker();
  final _dbManager = DatabaseManager();

  AppUser? _user;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = await _dbManager.getUserByEmail(widget.email);
    if (user != null) {
      setState(() {
        _user = user;
        _email = user.email;
        _username.text = user.fname;
        _phoneNumber.text = user.phone;
        _photoPath = user.photoPath;
        _imageFile = (_photoPath != null && _photoPath!.isNotEmpty)
            ? File(_photoPath!)
            : null;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await picker.pickImage(source: source, imageQuality: 70);
      if (picked != null) {
        setState(() {
          _imageFile = File(picked.path);
          _photoPath = picked.path;
        });
      }
    } catch (e) {
      debugPrint("Image pick error: $e");
    }
  }

  Future<void> _updateProfile() async {
    if (_user == null) return;

    final updatedUser = AppUser(
      id: _user!.id,
      fname: _username.text,
      lname: _user!.lname,
      email: _user!.email,
      password: _user!.password,
      phone: _phoneNumber.text,
      photoPath: _photoPath ?? '',
    );

    await _dbManager.updateAppUser(AppUser(
        id: _user!.id,
        fname: _username.text,
        lname: _user!.lname,
        email: _user!.email,
        password: _user!.password,
        phone: _phoneNumber.text,
        photoPath: _photoPath ?? ''));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Success"),
        content: const Text("Your changes have been saved."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _loadProfile(); // reload fresh data
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _cancelChanges() {
    if (_user != null) {
      setState(() {
        _username.text = _user!.fname;
        _phoneNumber.text = _user!.phone;
        _photoPath = _user!.photoPath;
        _imageFile = (_photoPath != null && _photoPath!.isNotEmpty)
            ? File(_photoPath!)
            : null;
      });
    }
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Profile",
          style: TextStyle(color: Color(0xff050c20)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.arrow_uturn_right,
                color: Color(0xff050c20)),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : const AssetImage('assets/images/apple.png')
                              as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (_) => Wrap(
                                    children: [
                                      ListTile(
                                        leading: const Icon(
                                            CupertinoIcons.camera_fill),
                                        title: const Text('Camera'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _pickImage(ImageSource.camera);
                                        },
                                      ),
                                      ListTile(
                                        leading:
                                            const Icon(CupertinoIcons.photo),
                                        title: const Text('Gallery'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _pickImage(ImageSource.gallery);
                                        },
                                      ),
                                    ],
                                  ));
                        },
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
                const SizedBox(height: 20),
                Mytextfield(
                  controller: _username,
                  hintText: 'Username',
                  obscureText: false,
                  leadingIcon: const Icon(CupertinoIcons.person_fill),
                ),
                const SizedBox(height: 20),
                Mytextfield(
                  controller: TextEditingController(text: _email ?? ''),
                  hintText: 'Email',
                  obscureText: false,
                  leadingIcon: const Icon(CupertinoIcons.mail_solid),
                ),
                const SizedBox(height: 20),
                Mytextfield(
                  controller: _phoneNumber,
                  hintText: 'Phone',
                  obscureText: false,
                  leadingIcon: const Icon(CupertinoIcons.phone_fill),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MyButton(
                        textbutton: 'Update',
                        onTap: _updateProfile,
                        buttonHeight: 40,
                        buttonWidth: 100,
                      ),
                      MyButton(
                        textbutton: 'Cancel',
                        onTap: _cancelChanges,
                        buttonHeight: 40,
                        buttonWidth: 100,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: MyNavBar(currentIndex: 3),
    );
  }
}
