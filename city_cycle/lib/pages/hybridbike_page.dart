import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:city_cycle/models/cycle_model.dart';
import 'package:city_cycle/pages/add_page.dart';

class HybridBikePage extends StatefulWidget {
  const HybridBikePage({super.key});

  @override
  State<HybridBikePage> createState() => _HybridBikePageState();
}

class _HybridBikePageState extends State<HybridBikePage> {
  List<CycleModel> hybridBikes = [];

  @override
  void initState() {
    super.initState();
    fetchHybridBikes();
  }

  Future<void> fetchHybridBikes() async {
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
        hybridBikes = data.map<CycleModel>((bike) {
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
        })
        .where((bike) => bike.type.toLowerCase() == 'hybrid')
        .toList();

        
      });
    } else {
      throw Exception("Failed to load prices");
    }
  } else {
    throw Exception("Failed to load bikes");
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hybrid Bikes")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: hybridBikes.length,
          itemBuilder: (context, index) {
            final bike = hybridBikes[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                leading: Image.asset(bike.imageUrl, width: 70, fit: BoxFit.cover),
                title: Text(bike.name),
                subtitle: Text(
                    "${bike.location} • Rs. ${bike.price} • ${bike.isAvailable ? "Available" : "Not Available"}"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPage(bikeName: bike.name),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
