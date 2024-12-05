class CashFlowModel {
  final String? cash;
  final String? pos;
  final String? returnedParcel;
  final String? deliveredParcel;

  CashFlowModel({
    this.cash,
    this.pos,
    this.returnedParcel,
    this.deliveredParcel,
  });

  factory CashFlowModel.fromJson(Map<String, dynamic> json) {
    return CashFlowModel(
      cash: json['cash'] as String?,
      pos: json['pos'] as String?,
      returnedParcel: json['returned-parcel'] as String?,
      deliveredParcel: json['delivered-parcel'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cash': cash,
      'pos': pos,
      'returned-parcel': returnedParcel,
      'delivered-parcel': deliveredParcel,
    };
  }
}
