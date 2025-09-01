import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart';

/// Catalog of button counts for input devices keyed by `hexId`.
final Map<String, int> _buttonCountCatalog = {};
bool _buttonCountsLoaded = false;

Future<void> loadButtonCountCatalog() async {
  if (_buttonCountsLoaded) return;
  _buttonCountsLoaded = true;

  const inputXmlPath = 'assets/xml/inputdevices.xml';

  try {
    String xmlString;
    try {
      xmlString = await rootBundle.loadString(inputXmlPath);
    } catch (_) {
      xmlString = File(inputXmlPath).readAsStringSync();
    }
    final document = XmlDocument.parse(xmlString);
    final devices = document.findAllElements('inputdevice');
    for (final device in devices) {
      final hexIdNode = device.getElement('hexId');
      if (hexIdNode == null) continue;
      final hexId = hexIdNode.innerText.trim().toLowerCase();
      if (hexId.isEmpty) continue;

      int? count;
      final pointsText = device.getElement('points')?.innerText ?? '';
      if (pointsText.isNotEmpty) {
        final parts = pointsText.split(',');
        final buttons = parts.where(
          (p) => p.trim().toLowerCase().startsWith('button'),
        );
        if (buttons.isNotEmpty) {
          count = buttons.length;
        }
      }

      if (count == null) {
        final schemeText = device.getElement('addressScheme')?.innerText ?? '';
        if (schemeText.isNotEmpty) {
          final numbers = schemeText
              .split(',')
              .map((e) => int.tryParse(e.trim()))
              .whereType<int>()
              .toList();
          if (numbers.isNotEmpty) {
            count = numbers.takeWhile((n) => n < 9).length;
          }
        }
      }

      if (count != null && count > 0) {
        _buttonCountCatalog[hexId] = count;
      }
    }
  } catch (_) {
    // Ignore parsing errors so the catalog remains partial.
  }
}

/// Returns the button count for a device type [code] if known.
int? buttonCountForTypeCode(int code) {
  final hexId = code.toRadixString(16).toLowerCase();
  return _buttonCountCatalog[hexId];
}
