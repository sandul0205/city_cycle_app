class CycleModel {
  final String id;
  final String name;
  final String type;
  final double price;
  final String imageUrl;
  final bool isAvailable;
  final String location;

  CycleModel({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.imageUrl,
    required this.isAvailable,
    required this.location,
  });

  factory CycleModel.fromJson(Map<String, dynamic> json) {
    return CycleModel(
      id: json['id'].toString(),
      name: json['name'],
      type: json['type'],
      price: double.parse(json['price'].toString()),
      imageUrl: 'assets/mountain.jpg', 
      isAvailable: json['isAvailable'] == 1,
      location: json['location'],
    );
  }
}
