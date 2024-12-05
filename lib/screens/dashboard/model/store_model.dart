class Store {
  final int? id;
  final String? storeName;
  final String? vatNo;
  final String? crNo;
  final String? storeLocation;
  final String? pointOfContact;
  final String? whatsappNumber;
  final String? email;

  Store({
    this.id,
    this.storeName,
    this.vatNo,
    this.crNo,
    this.storeLocation,
    this.pointOfContact,
    this.whatsappNumber,
    this.email,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] as int?, // Map id from JSON
      storeName: json['name'] as String?,
      vatNo: json['vat_no'] as String?,
      crNo: json['cr_no'] as String?,
      storeLocation: json['location'] as String?,
      pointOfContact: json['point_of_contact'] as String?,
      whatsappNumber: json['whatsapp_number'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeName': storeName,
      'vatNo': vatNo,
      'crNo': crNo,
      'storeLocation': storeLocation,
      'pointOfContact': pointOfContact,
      'whatsappNumber': whatsappNumber,
      'email': email,
    };
  }
}
