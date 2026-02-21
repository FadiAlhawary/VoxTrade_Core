class CommandInterpretation {
  final int id;
  final int? voiceCommandId;
  final String? intent;
  final int? instrumentId;
  final double? quantity;
  final double? price;
  final int? currencyId;
  final bool? parsedSuccessfully;
  final String? errorMessage;

  CommandInterpretation({
    required this.id,
    this.voiceCommandId,
    this.intent,
    this.instrumentId,
    this.quantity,
    this.price,
    this.currencyId,
    this.parsedSuccessfully,
    this.errorMessage,
  });

  factory CommandInterpretation.fromJson(Map<String, dynamic> json) {
    return CommandInterpretation(
      id: json['id'],
      voiceCommandId: json['voice_command_id'],
      intent: json['intent'],
      instrumentId: json['instrument_id'],
      quantity: (json['quantity'] as num?)?.toDouble(),
      price: (json['price'] as num?)?.toDouble(),
      currencyId: json['currency_id'],
      parsedSuccessfully: json['parsed_successfully'],
      errorMessage: json['error_message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'voice_command_id': voiceCommandId,
      'intent': intent,
      'instrument_id': instrumentId,
      'quantity': quantity,
      'price': price,
      'currency_id': currencyId,
      'parsed_successfully': parsedSuccessfully,
      'error_message': errorMessage,
    };
  }
}