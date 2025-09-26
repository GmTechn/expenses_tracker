import 'dart:io';
import 'package:expenses_tracker/components/myappbar.dart';
import 'package:expenses_tracker/components/mybutton.dart';
import 'package:expenses_tracker/components/mynavbar.dart';
import 'package:expenses_tracker/components/mytextfield.dart';
import 'package:expenses_tracker/management/database.dart';
import 'package:expenses_tracker/management/sessionmanager.dart';
import 'package:expenses_tracker/models/users.dart';
import 'package:expenses_tracker/pages/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ added

class ProfilePage extends StatefulWidget {
  final String email;
  const ProfilePage({super.key, required this.email});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
//--- Generating textfield controllers
  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

//---Generating a file to locally store images, profile pictures
//---Generating a string to hold the image string = photoPath
//---Generating a user's instance

  File? _imageFile;
  String? _photoPath;
  AppUser? _user;

//Generating a picker to pick images from both gallery and camera

  final _picker = ImagePicker();

//---Generating an instance of the database

  final DatabaseManager _databaseManager = DatabaseManager();

//--Checking is the user is logged in with a boolean

  bool _isLoading = false;

//---Initialising state

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

//---Disposing of the controllers after they held a value

  @override
  void dispose() {
    _fnameController.dispose();
    _lnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

//checking the state of the profile in the data
//si le profile existe, it gets loaded with the recently saved data
//en initializing la base de données

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      await _databaseManager.initialisation();
    } catch (_) {}

    // ✅ First, check SharedPreferences for saved photoPath
    final prefs = await SharedPreferences.getInstance();
    final savedPhotoPath = prefs.getString('profile_photo_${widget.email}');
    if (savedPhotoPath != null && savedPhotoPath.isNotEmpty) {
      final f = File(savedPhotoPath);
      if (f.existsSync()) {
        _imageFile = f;
        _photoPath = savedPhotoPath;
      }
    }

    AppUser? user;
    try {
      user = await _databaseManager.getUserByEmail(widget.email);
    } catch (_) {
      try {
        user = await _databaseManager.getUserByEmail(widget.email);
      } catch (_) {
        user = null;
      }
    }

    if (!mounted) return;

    if (user != null) {
      if ((user.fname ?? '').isNotEmpty) {
        _fnameController.text = user.fname;
      }
      if ((user.lname ?? '').isNotEmpty) {
        _lnameController.text = user.lname;
      }

      if ((user.email ?? '').isNotEmpty) {
        _emailController.text = user.email;
      } else if (_emailController.text.isEmpty) {
        _emailController.text = widget.email;
      }
      if ((user.phone ?? '').isNotEmpty) {
        _phoneController.text = user.phone;
      }

      // Only update image if SharedPreferences didn't already have it
      if ((_photoPath == null || _photoPath!.isEmpty) &&
          user.photoPath != null &&
          user.photoPath!.isNotEmpty) {
        final f = File(user.photoPath!);
        if (f.existsSync()) {
          _imageFile = f;
          _photoPath = user.photoPath;
        }
      }

      _user = user;
    } else {
      if (_emailController.text.isEmpty && widget.email.isNotEmpty) {
        _emailController.text = widget.email;
      }
    }

    setState(() => _isLoading = false);
  }

//----Generating the pick image function
//---Picking the image from a source and setting it's quality to 70

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 70);
      if (picked != null) {
        setState(() {
          _imageFile = File(picked.path);
          _photoPath = picked.path;
        });

        // ✅ Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'profile_photo_${widget.email}', _photoPath ?? '');

        if (_user != null) {
          final updated = AppUser(
            id: _user!.id,
            fname: _user!.fname,
            lname: _user!.lname,
            email: _user!.email,
            password: _user!.password,
            phone: _user!.phone,
            photoPath: _photoPath ?? '',
          );
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

  Future<void> _updateProfile() async {
    final updated = AppUser(
      id: _user?.id,
      fname: _fnameController.text.trim(),
      lname: _lnameController.text.trim(),
      email: _emailController.text.trim(),
      password: _user?.password ?? '',
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
          builder: (_) => const AlertDialog(
            backgroundColor: Color(0xff181a1e),
            title: Text(
              'Success',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Your changes have been saved.',
              style: TextStyle(color: Colors.white),
            ),
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
        backgroundColor: const Color(0xff181a1e),
        title: const Text(
          'Discard changes?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to discard your edits?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text(
                    'No',
                    style: TextStyle(color: Colors.white),
                  )),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text(
                    'Yes',
                    style: TextStyle(color: Colors.white),
                  )),
            ],
          ),
        ],
      ),
    );

    if (doCancel == true) {
      await _loadProfile();
    }
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

  void _logout() async {
    if (_user != null) {
      await SessionManager.saveCurrentUser(_user!.email);
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPage(email: _user?.email ?? ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff181a1e),
      appBar: myAppBar(
        context,
        'P R O F I L E',
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
                    SizedBox(height: 40),
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
                    const SizedBox(height: 50),
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
                    const SizedBox(height: 80),
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
