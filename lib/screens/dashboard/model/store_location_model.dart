class StoreLocationModel {
  final int? id;
  final String? createdAt;
  final String? name;
  final String? vatNo;
  final String? crNo;
  final String? location;
  final String? latitude;
  final String? longitude;
  final String? pointOfContact;
  final String? whatsappNumber;
  final String? email;
  final String? qrCodeImage;

  StoreLocationModel({
    this.id,
    this.createdAt,
    this.name,
    this.vatNo,
    this.crNo,
    this.location,
    this.latitude,
    this.longitude,
    this.pointOfContact,
    this.whatsappNumber,
    this.email,
    this.qrCodeImage,
  });
  factory StoreLocationModel.fromJson(Map<String, dynamic> json) {
    return StoreLocationModel(
      id: json['id'] as int?,
      createdAt: json['created_at'] as String?,
      name: json['name'] as String?,
      vatNo: json['vat_no'] as String?,
      crNo: json['cr_no'] as String?,
      location: json['location'] as String?,
      latitude: json['latitude'] as String?, // Ensure it's a double
      longitude: json['longitude'] as String?, // Ensure it's a double
      pointOfContact: json['point_of_contact'] as String?,
      whatsappNumber: json['whatsapp_number'] as String?,
      email: json['email'] as String?,
      qrCodeImage: json['qr_code_image'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'name': name,
      'vat_no': vatNo,
      'cr_no': crNo,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'point_of_contact': pointOfContact,
      'whatsapp_number': whatsappNumber,
      'email': email,
      'qr_code_image': qrCodeImage,
    };
  }
}
