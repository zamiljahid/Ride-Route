class PendingStoreModel {
  final int id;
  final String createdAt;
  final String status;
  final int driver;
  final int warehouse;
  final List<int> products;

  PendingStoreModel({
    required this.id,
    required this.createdAt,
    required this.status,
    required this.driver,
    required this.warehouse,
    required this.products,
  });

  factory PendingStoreModel.fromJson(Map<String, dynamic> json) {
    return PendingStoreModel(
      id: json['id'],
      createdAt: json['created_at'],
      status: json['status'],
      driver: json['driver'],
      warehouse: json['warehouse'],
      products: List<int>.from(json['products']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'status': status,
      'driver': driver,
      'warehouse': warehouse,
      'products': products,
    };
  }
}
