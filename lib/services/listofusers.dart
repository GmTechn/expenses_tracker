import 'package:expenses_tracker/components/mytextfield.dart';
import 'package:expenses_tracker/models/users.dart';
import 'package:flutter/cupertino.dart';
import 'package:expenses_tracker/management/database.dart';
import 'package:flutter/material.dart';

import 'package:expenses_tracker/components/myappbar.dart';

class ListOfUsers extends StatefulWidget {
  const ListOfUsers({super.key});

  @override
  State<ListOfUsers> createState() => _ListOfUsersState();
}

class _ListOfUsersState extends State<ListOfUsers> {
  final TextEditingController searchController = TextEditingController();

  // Users list
  List<AppUser> _users = [];

  ///users to filter and make use of the search bar

  List<AppUser> _filteredUsers = [];

  //calling the database

  final DatabaseManager _databaseManager = DatabaseManager();

//initialising db state
  @override
  void initState() {
    super.initState();
    _initDb();
  }

//loading users from the db

  Future<void> _initDb() async {
    await _databaseManager.initialisation();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await _databaseManager.getAllAppUsers();
    setState(() {
      _users = users.cast<AppUser>();
      _filteredUsers = users.cast<AppUser>();
    });
  }

  // Search
  void _searchUsers(String query) {
    final results = _users.where((user) {
      final fullName = '${user.fname} ${user.lname}'.toLowerCase();
      final email = (user.email ?? '').toLowerCase();
      return fullName.contains(query.toLowerCase()) ||
          email.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredUsers = results;
    });
  }

  // Delete user
  Future<void> _deleteUser(AppUser user) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete this user?"),
        content: Text("Are you sure you want to delete ${user.fname}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && user.id != null) {
      await _databaseManager.deleteAppUser(user.id!);
      _loadUsers();
    }
  }

  // Edit user
  Future<void> _editUser(AppUser user) async {
    final newFname = TextEditingController(text: user.fname);
    final newLname = TextEditingController(text: user.lname);
    final newEmail = TextEditingController(text: user.email);
    final newPassword = TextEditingController(text: user.password);
    final newPhone = TextEditingController(text: user.phone);

    await showDialog(
      context: context,
      builder: (context) {
        bool isPasswordVisible = false;

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text(
              textAlign: TextAlign.center,
              'Edit user info',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyTextFormField(
                    controller: newFname,
                    hintText: 'First Name',
                    obscureText: false,
                    leadingIcon: const Icon(
                      CupertinoIcons.person,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  MyTextFormField(
                    controller: newLname,
                    hintText: 'Last Name',
                    obscureText: false,
                    leadingIcon: const Icon(
                      CupertinoIcons.person,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  MyTextFormField(
                    controller: newEmail,
                    hintText: 'Email',
                    obscureText: false,
                    leadingIcon: const Icon(
                      CupertinoIcons.mail,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  MyTextFormField(
                    controller: newPassword,
                    hintText: 'Password',
                    obscureText: !isPasswordVisible,
                    leadingIcon: const Icon(
                      CupertinoIcons.lock,
                      color: Colors.white,
                    ),
                    trailingIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? CupertinoIcons.eye_fill
                            : CupertinoIcons.eye_slash_fill,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  MyTextFormField(
                    controller: newPhone,
                    hintText: 'Phone Number',
                    obscureText: false,
                    leadingIcon: const Icon(
                      CupertinoIcons.phone,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final updatedUser = AppUser(
                    id: user.id,
                    fname: newFname.text,
                    lname: newLname.text,
                    email: newEmail.text,
                    password: newPassword.text,
                    phone: newPhone.text,
                    photoPath: user.photoPath,
                  );

                  await _databaseManager.upsertAppUser(updatedUser as AppUser);

                  Navigator.pop(context);
                  _loadUsers();
                },
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  ///disposing of the search controller after making use
  ///of it for searching through the database

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff181a1e),
      appBar: myAppBar(context, 'U S E R S'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              cursorColor: const Color(0xff050c20),
              controller: searchController,
              onChanged: _searchUsers,
              decoration: InputDecoration(
                focusedBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xff050c20), width: 1.5)),
                prefixIcon: const Icon(Icons.search, color: Color(0xff050c20)),
                hintText: "Search users...",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xff050c20))),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListTile(
                      title: Text('${user.fname} ${user.lname}'),
                      subtitle: Text(user.email ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () => _deleteUser(user),
                              icon: const Icon(
                                CupertinoIcons.delete_solid,
                                color: Colors.red,
                              )),
                          IconButton(
                            onPressed: () => _editUser(user),
                            icon: const Icon(
                              CupertinoIcons.pencil,
                              color: Color(0xff181a1e),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
