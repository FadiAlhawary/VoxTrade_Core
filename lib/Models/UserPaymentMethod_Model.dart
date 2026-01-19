class UserPaymentMethod {
  final int id;
  final int? userId;
  final int? paymentMethodId;
  final String? attributeValue1;
  final String? attributeValue2;

  UserPaymentMethod({
    required this.id,
    this.userId,
    this.paymentMethodId,
    this.attributeValue1,
    this.attributeValue2,
  });

  factory UserPaymentMethod.fromJson(Map<String, dynamic> json) {
    return UserPaymentMethod(
      id: json['id'],
      userId: json['user_id'],
      paymentMethodId: json['payment_method_id'],
      attributeValue1: json['attribute_value_1'],
      attributeValue2: json['attribute_value_2'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'payment_method_id': paymentMethodId,
        'attribute_value_1': attributeValue1,
        'attribute_value_2': attributeValue2,
      };
}