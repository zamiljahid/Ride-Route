class ProductModel {
  int? id;
  String? name;
  String? boxCode;
  String? itemCode;
  String? buyingPrice;
  String? sellingPrice;
  String? status;
  int? warehouse;

  ProductModel({
    this.id,
    this.name,
    this.boxCode,
    this.itemCode,
    this.buyingPrice,
    this.sellingPrice,
    this.status,
    this.warehouse,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      boxCode: json['box_code'] as String?,
      itemCode: json['item_code'] as String?,
      buyingPrice: json['buying_price'] as String?,
      sellingPrice: json['selling_price'] as String?,
      status: json['status'] as String?,
      warehouse: json['warehouse'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'box_code': boxCode,
      'item_code': itemCode,
      'buying_price': buyingPrice,
      'selling_price': sellingPrice,
      'status': status,
      'warehouse': warehouse,
    };
  }
}
