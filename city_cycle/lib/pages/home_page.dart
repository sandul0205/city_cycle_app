import 'dart:convert';

import 'package:city_cycle/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:city_cycle/pages/mountainbike_page.dart';
import 'package:city_cycle/pages/hybridbike_page.dart';
import 'package:city_cycle/pages/electricbike_page.dart';
import 'package:shared_preferences/shared_preferences.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

}
  
class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  final DateFormat formatter = DateFormat('EEEE, MMMM dd');
  List<UserModel> users = [];
  String greetUser() {
  final currentTime = DateTime.now();
  final hour = currentTime.hour;
      if (hour < 12) {
        return 'Good Morning';
      } else if (hour < 18) {
        return 'Good Afternoon';
      } else {
        return 'Good Evening';
      }
}

  Future<void> fetchUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');

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
            ),
          ];
        });
      }
    } else {
      print("Error fetching user data");
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = formatter.format(now);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey),
                ),
                users.isNotEmpty
                  ? Text(
                      "Hi ${users[0].name}, ${greetUser()}",
                      style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
                    )
                  : const Text(
                      "Hi there!",
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
                    ),

                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    "Select Your Bike Type",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MountainBikePage()),
                            );
                          },
                          child: _bikeOption("assets/mountain.jpg", "Rent Mountain"),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const HybridBikePage()),
                            );
                          },
                          child: _bikeOption("assets/hybridbike.jpg", "Rent Hybrid"),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ElectricBikePage()),
                            );
                          },
                          child: _bikeOption("assets/electric.jpeg", "Rent Electric"),
                        ),
                      ],
                    ),


                const SizedBox(height: 20),

                _sectionContainer(
                  title: "Price List",
                  children: [
                    _priceTile("Mountain Bike", "\$12.00/day", Colors.green[100]!),
                    _priceTile("Hybrid Bike", "\$10.00/day", Colors.yellow[100]!),
                    _priceTile("Electric Bike", "\$20.00/day", Colors.red[100]!),
                  ],
                ),

                _sectionContainer(
                  title: "Promotions And Offers",
                  children: [
                    _promoTile("Get 10% off on your first rental!", Colors.green[100]!),
                    _promoTile("Exclusive Membership: Get access to special discounts!", Colors.blue[100]!),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

Widget _bikeOption(String imgPath, String label) {
  return Column(
    children: [
      Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            imgPath,
            fit: BoxFit.cover, 
          ),
        ),
      ),
      const SizedBox(height: 5),
      Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    ],
  );
}


  Widget _sectionContainer({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white, // White background
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12, 
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(title), 
          const SizedBox(height: 10),
          ...children, 
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.lightBlue[100],
      ),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _priceTile(String title, String price, Color bgColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        "$title: $price",
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _promoTile(String text, Color bgColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}
