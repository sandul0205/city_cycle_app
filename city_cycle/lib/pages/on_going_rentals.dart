import 'dart:convert';

import 'package:city_cycle/models/rental_model.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnGoingRentals extends StatefulWidget {
  const OnGoingRentals({super.key});

  @override
  State<OnGoingRentals> createState() => _OnGoingRentalsState();
}

class _OnGoingRentalsState extends State<OnGoingRentals> {
  List<RentalModel> rentals = [];

  @override
  void initState() {
    super.initState();
    fetchRentals();

  }

  Future<void> fetchRentals() async {
    var response = await http.get(Uri.parse("http://localhost:3000/ongoing_rentals"));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? user_Id = prefs.getInt('userId');
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        rentals = data.map<RentalModel>((rental) {
          return RentalModel(
            id: rental['id'].toString(),
            userId: rental['user_id'].toString(),
            name: rental['name'].toString(),
            location: rental['location'].toString(),
            startTime: DateTime.tryParse(rental['rental_date']),
            endTime: DateTime.tryParse(rental['end_rental_date']),
            cost: double.tryParse(rental['rental_cost'].toString()),
          );
        }).where((rental) => rental.userId == user_Id.toString())
        .toList();
        
      });
    } else {
      throw Exception("Failed to load rentals");
    }
  }

  Future<int> end_rental_cost(currentId) async {
    int endCost = 0;
    var response = await http.post(
      Uri.parse("http://localhost:3000/end_rental_cost"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'id': currentId,  
      }),
    );
    
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      endCost =  data['cost'];
    } else {
      throw Exception("Failed to load rental cost");
    }
    return endCost;
    
    
  }

  end_rental(RentalModel rental) async {
    var response = await http.post(
      Uri.parse("http://localhost:3000/end_rental"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',

        'Accept': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'id': rental.id ?? '',
        
      }),
    );

    if (response.statusCode == 200) {
      fetchRentals(); 
    } else {
      throw Exception("Failed to end rental");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('On Going Rentals'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: ListView.builder(
          itemCount: rentals.length,
          itemBuilder: (context, index) {
            final rental = rentals[index];
            
            return Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              shadowColor: Colors.grey.withOpacity(0.5),
              color: Colors.grey[200],
              
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text('Bike Name: ${rental.name}'),
                subtitle: Text(
                      'Bike Name: ${rental.name} \n'
                      'Bike Location: ${rental.location}\n'
                      'Start Time: ${DateFormat('yyyy-MM-dd').format(rental.startTime!)}\n'
                      'End Time: ${DateFormat('yyyy-MM-dd').format(rental.endTime!)}\n'
                      'Cost: \$${rental.cost?.toStringAsFixed(2)}',
                    ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                        if (await confirm(
                          context,
                          title: const Text('Confirm'),
                          content: const Text('Do you want to end this rental?'),
                          textOK: const Text('Yes'),
                          textCancel: const Text('No'),
                        )) {
                          int cost = await end_rental_cost(rental.id!);
                          if (await confirm(
                            context,
                            title: const Text('Confirm'),
                            content:  Text('Confirm rental details \nBike Name:${rental.name} \nLocation: ${rental.location}\nStart Time: ${DateFormat('yyyy-MM-dd').format(rental.startTime!)}\nEnd Time: ${DateFormat('yyyy-MM-dd').format(rental.endTime!)}\nRental Cost for this period: \$${cost.toStringAsFixed(2)}'),
                            textOK: const Text('Yes'),
                            
                            textCancel: const Text('No'),
                          )) {
                            end_rental(rental);
                            
                          } else {
                            return;
                          }
                                                    
                        }
                      },
                  
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}