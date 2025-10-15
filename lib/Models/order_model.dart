class OrderModel {
  final String id;
  final String pickup;
  final String dropoff;
  final String eta;
  final String type;
  final String status; // 'Pending','Accepted','In-Transit','Completed'
  final double distanceKm;

  OrderModel({
    required this.id,
    required this.pickup,
    required this.dropoff,
    required this.eta,
    required this.type,
    required this.status,
    required this.distanceKm,
  });

  factory OrderModel.fromJson(Map<String, dynamic> j) => OrderModel(
    id: j['id'].toString(),
    pickup: j['pickup'] ?? '',
    dropoff: j['dropoff'] ?? '',
    eta: j['eta'] ?? '',
    type: j['type'] ?? '',
    status: j['status'] ?? '',
    distanceKm: (j['distanceKm'] ?? 0).toDouble(),
  );
}