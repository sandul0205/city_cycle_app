import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:city_cycle/pages/add_page.dart';
import 'package:city_cycle/models/cycle_model.dart'; 

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  List<CycleModel> allBikes = [];
  List<CycleModel> filteredList = [];
  String searchText = '';

  @override
  void initState() {
    super.initState();
    getAllBikes();
  }

  Future<void> getAllBikes() async {
  var response = await http.get(Uri.parse("http://localhost:3000/bikes"));
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);

    var priceRes = await http.get(Uri.parse("http://localhost:3000/prices"));
    if (priceRes.statusCode == 200) {
      var priceData = jsonDecode(priceRes.body);

      Map<String, double> typePrices = {};
      for (var item in priceData) {
        typePrices[item['type']] = double.parse(item['cost'].toString());
      }

      setState(() {
        allBikes = data.map<CycleModel>((bike) {
          double price = typePrices[bike['type']] ?? 0.0;
          return CycleModel(
            id: bike['id'].toString(),
            name: bike['name'],
            type: bike['type'],
            price: price,
            imageUrl: 'assets/mountain.jpg',
            isAvailable: bike['isAvailable'] == 1,
            location: bike['location'],
          );
        }).toList();

        filteredList = allBikes;
      });
    } else {
      throw Exception("Failed to load prices");
    }
  } else {
    throw Exception("Failed to load bikes");
  }
}

  void _searchBikes(String text) {
    setState(() {
      searchText = text;
      filteredList = allBikes.where((bike) =>
        bike.location.toLowerCase().contains(text.toLowerCase())
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search by Location")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              TextField(
                onChanged: _searchBikes,
                decoration: InputDecoration(
                  labelText: "Search by location",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final bike = filteredList[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Image.asset(
                          bike.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                        title: Text(bike.name),
                        subtitle: Text(
                            "${bike.type} • ${bike.location} • Rs. ${bike.price}"),
                        trailing: Icon(
                          bike.isAvailable
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: bike.isAvailable
                              ? Colors.green
                              : Colors.red,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddPage(bikeName: bike.name),
                            ),
                          ).then((_) => getAllBikes()
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
