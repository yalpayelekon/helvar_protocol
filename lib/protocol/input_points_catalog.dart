import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart';

import '../models/helvar_models/input_point.dart';

class InputPointSpec {
  final String label;
  final int id;

  InputPointSpec(this.label, this.id);
}

final Map<String, List<InputPointSpec>> _pointsCatalog = {};
bool _pointsLoaded = false;

Future<void> loadInputPointsCatalog() async {
  if (_pointsLoaded) return;
  _pointsLoaded = true;

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

      final pointsText = device.getElement('points')?.innerText ?? '';
      if (pointsText.isEmpty) continue;
      final labels = pointsText.split(',').map((e) => e.trim()).toList();

      final schemeText = device.getElement('addressScheme')?.innerText ?? '';
      final ids = schemeText
          .split(',')
          .map((e) => int.tryParse(e.trim()))
          .whereType<int>()
          .toList();

      final specs = <InputPointSpec>[];
      for (var i = 0; i < labels.length; i++) {
        final label = labels[i];
        final id = i < ids.length ? ids[i] : i + 1;
        specs.add(InputPointSpec(label, id));
      }

      if (specs.isNotEmpty) {
        _pointsCatalog[hexId] = specs;
      }
    }
  } catch (_) {
    // Ignore parsing errors so the catalog remains partial.
  }
}

List<InputPointSpec>? pointSpecsForTypeCode(int code) {
  final hexId = code.toRadixString(16).toLowerCase();
  return _pointsCatalog[hexId];
}

InputPointType pointTypeFromLabel(String label) {
  final lower = label.toLowerCase();
  if (lower.startsWith('button')) return InputPointType.button;
  if (lower.startsWith('ir')) return InputPointType.ir;
  if (lower.startsWith('slider')) return InputPointType.slider;
  if (lower.startsWith('push')) return InputPointType.pushOnOff;
  if (lower.startsWith('numeric')) return InputPointType.inputNumeric;
  if (lower.startsWith('input')) return InputPointType.inputBool;
  if (lower.contains('pir') || lower.contains('occupancy')) {
    return InputPointType.pir;
  }
  if (lower.contains('light')) return InputPointType.lightSensor;
  return InputPointType.inputBool;
}
