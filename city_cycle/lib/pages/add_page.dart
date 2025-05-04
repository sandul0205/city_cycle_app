import 'package:city_cycle/pages/on_going_rentals.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPage extends StatefulWidget {
  final String? bikeName;

  const AddPage({super.key, this.bikeName});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  late TextEditingController _nameController;
  final TextEditingController _rentalDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  DateTime? _rentalDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.bikeName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rentalDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate({required bool isStart}) async {
    DateTime initialDate = isStart
        ? (_rentalDate ?? DateTime.now())
        : (_endDate ?? DateTime.now());

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        final formatted = DateFormat('yyyy-MM-dd').format(pickedDate);
        if (isStart) {
          _rentalDate = pickedDate;
          _rentalDateController.text = formatted;
        } else {
          _endDate = pickedDate;
          _endDateController.text = formatted;
        }
      });
    }
  }

  Future<void> _rentCycle() async {
    if (_nameController.text.isEmpty || _rentalDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');


    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in.")),
      );
      return;
    }

    final bikeName = _nameController.text;

    try {
      final bikeRes = await http.get(Uri.parse('http://localhost:3000/bike-id?name=$bikeName'));
      if (bikeRes.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bike not found.")),
        );
        return;
      }

      final bikeData = json.decode(bikeRes.body);
      final bikeId = bikeData['id'] ;

      var priceRes = await http.get(Uri.parse("http://localhost:3000/prices"));
      if (priceRes.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load prices.")),
        );
        return;
      }
      var priceData = json.decode(priceRes.body);
      // Create a map of type -> cost
      Map<String, double> typePrices = {};
      for (var item in priceData) {
        typePrices[item['type']] = double.parse(item['cost'].toString());
      }
      String bikeType = bikeData['type'];
      double rentalCost = typePrices[bikeType] ?? 0.0;
      if (_rentalDate != null && _endDate != null) {
        final duration = _endDate!.difference(_rentalDate!);
        rentalCost *= duration.inDays; 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid rental dates.")),
        );
        return;
      }

      final availabilityRes = await http.get(Uri.parse('http://localhost:3000/bike-availability?bike_id=$bikeId'));
      if (availabilityRes.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to check bike availability.")),
        );
        return;
      }

      final availabilityData = json.decode(availabilityRes.body);
      if (availabilityData['availability']==0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bike is not available.")),
        );
        return;
      }

      final updateRes = await http.post(
        Uri.parse('http://localhost:3000/update-bike-availability'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': bikeId,
          'isAvailable': 0,
        }),
        
      );
      if (updateRes.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update bike availability.")),
          
        );
        return;
      }
      
      final rentalRes = await http.post(
        Uri.parse('http://localhost:3000/rentals'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'bike_id': bikeId,
          'user_id': userId,
          'rental_date': _rentalDate!.toIso8601String(),
          'end_rental_date': _endDate!.toIso8601String(),
          'rental_cost':rentalCost,
        }),
      );

      if (rentalRes.statusCode == 200 || rentalRes.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cycle rented successfully!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const OnGoingRentals(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to rent cycle.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rent a Cycle"),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                "Rent a Cycle",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: "Cycle Name"),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _rentalDateController,
                        readOnly: true,
                        onTap: () => _selectDate(isStart: true),
                        decoration: const InputDecoration(
                          labelText: "Rental Date",
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _endDateController,
                        readOnly: true,
                        onTap: () => _selectDate(isStart: false),
                        decoration: const InputDecoration(
                          labelText: "End Rental Date",
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _rentCycle,
                        child: const Text("Rent Cycle"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
