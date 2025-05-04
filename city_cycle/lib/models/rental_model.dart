class RentalModel {
  String? id;
  String? userId;
  String? name;
  String? location;
  DateTime? startTime;
  DateTime? endTime;
  double? cost;

  RentalModel({
    this.id,
    this.userId,
    this.name,
    this.location,
    this.startTime,
    this.endTime,
    this.cost,
  });

  RentalModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    name = json['name'];
    location = json['location'];
    startTime = DateTime.tryParse(json['rental_date']);
    endTime = DateTime.tryParse(json['end_rental_date']);
    cost = double.tryParse(json['rental_cost'].toString());

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['name'] = name;
    data['location'] = location;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['cost'] = cost;
    return data;
  }
}