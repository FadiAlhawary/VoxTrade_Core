String displayMarketName(String symbol) {
  final normalized = symbol.contains(':') ? symbol.split(':').last : symbol;
  return normalized.replaceAll('_', '/');
}
