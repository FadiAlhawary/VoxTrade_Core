// Shared sign-in / sign-up rules: allowed email domains and password composition.

/// Only these domains are accepted (compare case-insensitively).
const Set<String> kAllowedEmailDomains = {'gmail.com'};

/// Symbols allowed in passwords. Others (quotes, semicolons, slashes, etc.) are
/// rejected to reduce SQL-injection-style character payloads in user input.
const String kAllowedPasswordSymbols = r'!@#$%^&*-_+=?';

final RegExp _emailLocalPart = RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9._+-]*$');
final RegExp _hasUpper = RegExp(r'[A-Z]');
final RegExp _hasDigit = RegExp(r'[0-9]');
final Set<String> _symbolSet = kAllowedPasswordSymbols.split('').toSet();

final RegExp _asciiLetterOrDigit = RegExp(r'[a-zA-Z0-9]');

bool _passwordUsesOnlyAllowedCharacters(String password) {
  for (final int r in password.runes) {
    final String ch = String.fromCharCode(r);
    if (_asciiLetterOrDigit.hasMatch(ch)) {
      continue;
    }
    if (_symbolSet.contains(ch)) {
      continue;
    }
    return false;
  }
  return true;
}

/// Returns `null` if valid, otherwise a short message for [SnackBarComp].
String? validateAuthEmail(String email) {
  final String trimmed = email.trim();
  if (trimmed.isEmpty) {
    return 'Please enter your email address.';
  }
  final int at = trimmed.indexOf('@');
  if (at <= 0) {
    return 'Please enter a valid email address.';
  }
  final String local = trimmed.substring(0, at);
  final String domain = trimmed.substring(at + 1).toLowerCase();
  if (local.isEmpty || domain.isEmpty) {
    return 'Please enter a valid email address.';
  }
  if (!_emailLocalPart.hasMatch(local)) {
    return 'Use a valid Gmail address (letters, numbers, . _ + -).';
  }
  if (!kAllowedEmailDomains.contains(domain)) {
    return 'Please use @gmail.com.';
  }
  return null;
}

/// Returns `null` if valid, otherwise a multiline message for [SnackBarComp]
/// listing every requirement that is not met.
String? validateAuthPassword(String password) {
  if (password.isEmpty) {
    return 'Please enter your password.';
  }

  final List<String> missing = <String>[];
  if (password.length < 8) {
    missing.add('At least 8 characters');
  }
  if (!_hasUpper.hasMatch(password)) {
    missing.add('At least 1 uppercase letter');
  }
  if (!_hasDigit.hasMatch(password)) {
    missing.add('At least 1 number (mixed with letters)');
  }
  if (!password.split('').any(_symbolSet.contains)) {
    missing.add('At least 1 symbol ($kAllowedPasswordSymbols)');
  }
  if (!_passwordUsesOnlyAllowedCharacters(password)) {
    missing.add(
      'Only use letters, numbers, and allowed symbols: $kAllowedPasswordSymbols',
    );
  }

  if (missing.isEmpty) {
    return null;
  }

  return 'Password must meet:\n${missing.map((String e) => '• $e').join('\n')}';
}
