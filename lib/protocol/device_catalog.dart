import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart';

import '../models/helvar_models/device_type.dart';
import 'device_types.dart';

class DeviceCatalog {
  static const Map<int, DeviceType> deviceTypeCatalog = {
    0x1: DeviceType.output,
    0x201: DeviceType.output,
    0x208: DeviceType.output,
    0x301: DeviceType.output,
    0x401: DeviceType.output,
    0x501: DeviceType.output,
    0x601: DeviceType.output,
    0x701: DeviceType.output,
    0x801: DeviceType.output,
    0x901: DeviceType.output,
    0x1001: DeviceType.output,
    0x1101: DeviceType.output,
    0xE404: DeviceType.output,
    0xE504: DeviceType.output,
    0xE604: DeviceType.output,
    0xE804: DeviceType.output,
    0xEF04: DeviceType.output,
    0xF004: DeviceType.output,
    0xF104: DeviceType.output,
    0xF204: DeviceType.output,
    0xF304: DeviceType.output,
    0xF404: DeviceType.output,
    0xF504: DeviceType.output,
    0xF604: DeviceType.output,
    0xF704: DeviceType.output,
    0xF804: DeviceType.output,
    0xF904: DeviceType.output,
    0xFA04: DeviceType.output,
    0xFB04: DeviceType.output,
    0xFC04: DeviceType.output,
    0xFE04: DeviceType.output,
    0x100802: DeviceType.input,
    0x110702: DeviceType.input,
    0x111402: DeviceType.input,
    0x121302: DeviceType.input,
    0x122002: DeviceType.input,
    0x124402: DeviceType.input,
    0x125102: DeviceType.input,
    0x126802: DeviceType.input,
    0x131202: DeviceType.input,
    0x132902: DeviceType.input,
    0x134302: DeviceType.input,
    0x135002: DeviceType.input,
    0x136702: DeviceType.input,
    0x137402: DeviceType.input,
    0x170102: DeviceType.input,
    0x311802: DeviceType.input,
    0x312502: DeviceType.input,
    0x313202: DeviceType.input,
    0x314902: DeviceType.input,
    0x315602: DeviceType.input,
    0x317002: DeviceType.input,
    0x318702: DeviceType.input,
    0x319402: DeviceType.input,
    0x320002: DeviceType.input,
    0x321702: DeviceType.input,
    0x322402: DeviceType.input,
    0x329302: DeviceType.input,
    0x416002: DeviceType.output,
    0x425202: DeviceType.output,
    0x434402: DeviceType.input,
    0x441202: DeviceType.input,
    0x444302: DeviceType.input,
    0x445002: DeviceType.input,
    0x452802: DeviceType.output,
    0x454202: DeviceType.output,
    0x455902: DeviceType.output,
    0x458002: DeviceType.output,
    0x458402: DeviceType.output,
    0x472602: DeviceType.output,
    0x474002: DeviceType.output,
    0x478802: DeviceType.output,
    0x490002: DeviceType.output,
    0x492402: DeviceType.output,
    0x493102: DeviceType.output,
    0x494802: DeviceType.output,
    0x498602: DeviceType.output,
    0x499302: DeviceType.output,
    0x804502: DeviceType.output,
    0x935602: DeviceType.input,
    0x939402: DeviceType.input,
    0x942402: DeviceType.input,
    0x1290502: DeviceType.input,
    0x1454102: DeviceType.output,
    0x1458902: DeviceType.output,
    0x2000801: DeviceType.output,
    0x2290402: DeviceType.input,
    0x4212402: DeviceType.output,
    0x4213102: DeviceType.output,
    0x4214802: DeviceType.output,
    0x4215502: DeviceType.output,
    0x4220902: DeviceType.output,
    0x4228502: DeviceType.output,
    0x4229202: DeviceType.output,
    0x4230802: DeviceType.output,
    0x4231502: DeviceType.output,
    0x4232202: DeviceType.output,
    0x4235302: DeviceType.output,
    0x4236002: DeviceType.output,
    0x4340402: DeviceType.output,
    0x4341102: DeviceType.output,
    0x4342802: DeviceType.output,
    0x4343502: DeviceType.output,
    0x4344202: DeviceType.output,
    0x4345902: DeviceType.output,
    0x4346602: DeviceType.output,
    0x4347302: DeviceType.output,
    0x4348002: DeviceType.output,
    0x4349702: DeviceType.output,
    0x4350302: DeviceType.output,
    0x4351002: DeviceType.output,
    0x4352702: DeviceType.output,
    0x4353402: DeviceType.output,
    0x4354102: DeviceType.output,
    0x4355802: DeviceType.output,
    0x4356502: DeviceType.output,
    0x4357202: DeviceType.output,
    0x4458602: DeviceType.output,
    0x4915402: DeviceType.output,
    0x4920802: DeviceType.output,
    0x4921502: DeviceType.output,
    0x4922202: DeviceType.output,
    0x4923902: DeviceType.output,
    0x4924602: DeviceType.output,
    0x4925302: DeviceType.output,
    0x4926002: DeviceType.output,
    0x4927702: DeviceType.output,
    0x4928402: DeviceType.output,
    0x4929102: DeviceType.output,
    0x4930702: DeviceType.output,
    0x4931402: DeviceType.output,
    0x4932102: DeviceType.output,
    0x4933802: DeviceType.output,
    0x4934502: DeviceType.output,
    0x4935202: DeviceType.output,
    0x5502502: DeviceType.output,
    0x5745901: DeviceType.input,
    0x5748001: DeviceType.input,
    0x5749701: DeviceType.input,
    0x6624601: DeviceType.input,
    0x6626001: DeviceType.input,
    0x7458302: DeviceType.output,
    0x9458102: DeviceType.output,
    0x11191202: DeviceType.input,
    0x11192902: DeviceType.input,
    0x11193602: DeviceType.input,
    0x12191102: DeviceType.input,
    0x12192802: DeviceType.input,
    0x12193502: DeviceType.input,
    0x21191902: DeviceType.input,
    0x21192602: DeviceType.input,
    0x21193302: DeviceType.input,
    0x22191802: DeviceType.input,
    0x22192502: DeviceType.input,
    0x22193202: DeviceType.input,
    0x49210302: DeviceType.input,
    0x49211002: DeviceType.input,
    0x55180002: DeviceType.output,
    0x55210402: DeviceType.output,
    0x55240102: DeviceType.output,
    0x55320002: DeviceType.output,
    0x55330902: DeviceType.output,
    0x55370502: DeviceType.output,
    0x55420702: DeviceType.output,
    0x55430602: DeviceType.output,
    0x55550102: DeviceType.output,
    0x55560002: DeviceType.output,
    0x55640902: DeviceType.output,
    0x55660702: DeviceType.output,
    0x57000902: DeviceType.output,
    0x80000001: DeviceType.input,
    0x80131801: DeviceType.input,
    0x80132501: DeviceType.input,
    0x80134901: DeviceType.input,
    0x80135601: DeviceType.input,
    0x80136301: DeviceType.input,
    0x80137001: DeviceType.input,
    0x80142401: DeviceType.input,
    0x80144801: DeviceType.input,
    0x80146201: DeviceType.input,
    0x80148601: DeviceType.input,
    0x80320601: DeviceType.input,
    0x80321301: DeviceType.input,
    0x80322001: DeviceType.input,
    0x80441801: DeviceType.input,
    0x80444901: DeviceType.input,
    0x81131701: DeviceType.input,
    0x81132401: DeviceType.input,
    0x81134801: DeviceType.input,
    0x81135501: DeviceType.input,
    0x81136201: DeviceType.input,
    0x81137901: DeviceType.input,
    0x81320501: DeviceType.input,
    0x81321201: DeviceType.input,
    0x81322901: DeviceType.input,
    0x82131601: DeviceType.input,
    0x82132301: DeviceType.input,
    0x82134701: DeviceType.input,
    0x82135401: DeviceType.input,
    0x82136101: DeviceType.input,
    0x82137801: DeviceType.input,
    0x82320401: DeviceType.input,
    0x82321101: DeviceType.input,
    0x83320301: DeviceType.input,
    0x83321001: DeviceType.input,
    0xFF000801: DeviceType.output,
  };

  /// Default icon path used when a specific icon is not available.
  static const String defaultIconPath = 'assets/icons/device.png';

  static final Map<String, String> _iconCatalog = {};
  static bool _iconsLoaded = false;

  static Future<void> initialize() async {
    await loadIconCatalog();
  }

  static Future<void> loadIconCatalog() async {
    if (_iconsLoaded) return;
    _iconsLoaded = true;

    const inputXmlPath = 'assets/xml/inputdevices.xml';
    const outputXmlPath = 'assets/xml/outputdevices.xml';

    for (final path in [inputXmlPath, outputXmlPath]) {
      try {
        String xmlString;
        try {
          xmlString = await rootBundle.loadString(path);
        } catch (_) {
          xmlString = File(path).readAsStringSync();
        }
        final document = XmlDocument.parse(xmlString);
        final entries = document.findAllElements('hexId');
        for (final hexIdNode in entries) {
          final parent = hexIdNode.parent;
          if (parent == null) continue;
          final iconNode = parent.getElement('icon');
          if (iconNode == null) continue;
          final hexId = hexIdNode.innerText.trim().toLowerCase();
          final iconPath = iconNode.innerText.trim();
          if (hexId.isNotEmpty && iconPath.isNotEmpty) {
            _iconCatalog[hexId] = iconPath;
          }
        }
      } catch (_) {
        // Ignore parsing errors, catalog will remain partial.
      }
    }
  }

  static DeviceType typeForCode(int code) =>
      deviceTypeCatalog[code] ?? DeviceType.output;

  /// Returns the recommended icon asset path for a device type code.
  static String iconPathForCode(int code) {
    final hexId = code.toRadixString(16).toLowerCase();

    final mapped = _iconCatalog[hexId];
    if (mapped != null) return mapped;

    if (isDeviceMultisensor(code)) {
      return 'assets/icons/sensor.png';
    }

    return defaultIconPath;
  }
}
