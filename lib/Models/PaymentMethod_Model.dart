class PaymentMethod {
  final int id;
  final String methodName;
  final String methodType;
  final int? formUiId;
  final int? status;

  PaymentMethod({
    required this.id,
    required this.methodName,
    required this.methodType,
    this.formUiId,
    this.status,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      methodName: json['mehtod_name'] ?? '', // Note typo 'mehtod' from database
      methodType: json['method_type'] ?? '',
      formUiId: json['form_uiid'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'mehtod_name': methodName,
        'method_type': methodType,
        'form_uiid': formUiId,
        'status': status,
      };
}
