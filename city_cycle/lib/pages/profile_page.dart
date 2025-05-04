import 'dart:convert';

import 'package:city_cycle/pages/edit_profile.dart';
import 'package:city_cycle/pages/login_page.dart';
import 'package:city_cycle/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:city_cycle/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
  
}

class _ProfilePageState extends State<ProfilePage> {
  List<UserModel> users = [];
  SharedPreferences? prefs;
  int? userId;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

 
  Future<void> initializePreferences() async {
    prefs = await SharedPreferences.getInstance();
    userId = prefs?.getInt('userId');
  }
  Future<void> fetchUserData() async {
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
        if (res['user'] != null) {
          setState(() {
            users = [
              UserModel(
                id: res['user']['Id'].toString(),
                name: res['user']['Name'],
                email: res['user']['Email'],
                phoneNumber: res['user']['Phone'],
              )
            ];
          });


        } else {
          print("User not found");
        }
      } else {
        print("Error fetching user data: ${data.statusCode}");
      }


  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: users.isEmpty
          ? const Center(child: CircularProgressIndicator()) 
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/user.jpg'),
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 16),

                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.person, color: Colors.deepPurple),
                            title: Text(users[0].name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.email, color: Colors.deepPurple),
                            title: Text(users[0].email),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.phone, color: Colors.deepPurple),
                            title: Text(users[0].phoneNumber),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.edit, color: Colors.blue),
                          title: const Text("Edit Profile"),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const EditProfile()),
                              ).then((value) {
                                fetchUserData(); 
                              });
                            
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.payment, color: Colors.green),
                          title: const Text("Payment Details"),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Navigate to Payment Details
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: Icon(Icons.settings, color: Colors.grey[700]),
                          title: const Text("Settings"),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Settings()),
                            );
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text("Logout"),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

}
