String generateId(String label, {String? address}) {
  final base = sanitizePathSegment(label);
  if (address != null && address.isNotEmpty) {
    return '${base}_${sanitizePathSegment(address)}';
  }
  return base;
}

String sanitizePathSegment(String input) {
  var sanitized = input.replaceAll(' ', '_');
  sanitized = sanitized.replaceAll('..', '');
  sanitized = sanitized.replaceAll(RegExp(r'[\\/]'), '');
  return sanitized;
}
