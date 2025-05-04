import 'dart:convert';

import 'package:city_cycle/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  int? userId;
  SharedPreferences? prefs;

  List<UserModel> users = [];
  @override
  void initState() {
    super.initState();
    _fetchUserData();
    
  }
  
  Future<UserModel> _fetchUserData()async{
    prefs = await SharedPreferences.getInstance();
    userId = prefs?.getInt('userId');
    var data = await http.post(
      Uri.parse("http://localhost:3000/user_data"),
      body: jsonEncode({
        'Id': userId,
      }),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (data.statusCode == 200) {
      var res = json.decode(data.body);
      if (res['success'] == true) {
        setState(() {
          _nameController.text = res['user']['Name'];
          _emailController.text = res['user']['Email'];
          _phoneController.text = res['user']['Phone'];
        });
        return UserModel.fromJson(res['data']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch user data")),
        );
        throw Exception("Failed to fetch user data");
      }
    } else {
      throw Exception("Failed to connect to the server");
    }
  }
  

  Future<UserModel> _updateUserData()async{
    prefs = await SharedPreferences.getInstance();
    userId = prefs?.getInt('userId');
    var data = await http.post(
      Uri.parse("http://localhost:3000/update_user"),
      body: jsonEncode({
        'Id': userId,
        'Name': _nameController.text,
        'Email': _emailController.text,
        'Phone': _phoneController.text,
      }),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (data.statusCode == 200) {
      var res = json.decode(data.body);
      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User data updated successfully")),
        );
        return UserModel.fromJson(res['data']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch user data")),
        );
        throw Exception("Failed to fetch user data");
      }
    } else {
      throw Exception("Failed to connect to the server");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile"),),
      body: SafeArea(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.all(16),
          color: Colors.white,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage("https://example.com/profile.jpg"),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _updateUserData().then((user) {
                        setState(() {
                          users.add(user);
                        });
                      }).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $error")),
                        );
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ),
          
          ),
        ),
      );
    
  }
}