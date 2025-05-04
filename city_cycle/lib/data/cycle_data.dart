import 'package:city_cycle/models/cycle_model.dart';

class CycleData {
  final List<CycleModel> cycleDataList = [
    CycleModel(
      id: '1',
      name: 'Mountain Bike',
      type: 'Mountain',
      price: 15000,
      imageUrl: 'assets/mountain.jpg',
      isAvailable: true,
      location: 'Colombo',
    ),
    CycleModel(
      id: '2',
      name: 'Hybrid Bike',
      type: 'Hybrid',
      price: 18000,
      imageUrl: 'assets/mountain.jpg',
      isAvailable: true,
      location: 'Galle',
    ),
    CycleModel(
      id: '3',
      name: 'Electric Bike',
      type: 'Electric',
      price: 25000,
      imageUrl: 'assets/mountain.jpg',
      isAvailable: false,
      location: 'Negombo',
    ),
    CycleModel(
      id: '4',
      name: 'Advanced Mountain Bike',
      type: 'Mountain',
      price: 20000,
      imageUrl: 'assets/mountain.jpg',
      isAvailable: true,
      location: 'Kandy',
    ),
    CycleModel(
      id: '5',
      name: 'City Hybrid Bike',
      type: 'Hybrid',
      price: 17000,
      imageUrl: 'assets/mountain.jpg',
      isAvailable: true,
      location: 'Matara',
    ),
    CycleModel(
      id: '6',
      name: 'Eco Electric Bike',
      type: 'Electric',
      price: 24000,
      imageUrl: 'assets/mountain.jpg',
      isAvailable: true,
      location: 'Jaffna',
    ),
  ];
}
