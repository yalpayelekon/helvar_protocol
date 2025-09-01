import 'button_count_catalog.dart';

/// Commonly referenced DALI device type codes.
class DaliDeviceTypeCode {
  static const int fluorescentLamps = 0x0001;
  static const int incandescentLamps = 0x0401;
  static const int ledModules = 0x0601;
}

bool isButtonDevice(int typeCode) {
  final protocol = typeCode & 0xFF;
  final series = (typeCode >> 16) & 0xFF;
  final prefix = (typeCode >> 24) & 0xFF;

  return typeCode == 1265666 || // Button 135
      typeCode == 1271554 || // Button 136
      typeCode == 1274882 || // Button 137
      typeCode == 1200386 || // Button 125
      typeCode == 1206274 || // Button 126
      typeCode == 1184514 || // Button 121
      typeCode == 1197058 || // Button 124
      typeCode == 1262338 || // Button 134
      typeCode == 1442306 || // Button 160
      // Generic digidim button panels
      (protocol == 0x02 &&
          (series == 0x12 || // 12x series button panels
              series == 0x13 || // 13x series button panels
              series == 0x93 || // 93x series scene commanders
              prefix == 0x82)) || // 82x series touchpanels
      // DALI-2 button panels (e.g. 13x series with 0x80/0x81 prefixes)
      (protocol == 0x01 && series == 0x13 && prefix >= 0x80);
}

bool isDeviceMultisensor(int typeCode) {
  final protocol = typeCode & 0xFF;
  final series = (typeCode >> 16) & 0xFF;
  final prefix = (typeCode >> 24) & 0xFF;

  // Digidim multisensors: 31x and 32x series (e.g. 311, 312, 320‑322).
  if (protocol == 0x02 && series >= 0x31 && series <= 0x32) {
    return true;
  }

  // DALI‑2 multisensors: 32x series with a prefix of 0x80 or higher.
  if (protocol == 0x01 && prefix >= 0x80 && series == 0x32) {
    return true;
  }

  // Steinel multisensors with unique IDs.
  const steinelIds = {
    0x5749701, // IR Quattro HD
    0x5748001, // HF 360
    0x5745901, // Dual HF
    0x6624601, // IS 3360 MX
    0x6626001, // IS 345 MX
  };
  if (steinelIds.contains(typeCode)) {
    return true;
  }

  // Fallback to the original 0x31xx02 pattern used by older sensors.
  return protocol == 0x02 && ((typeCode >> 8) & 0xFF) == 0x31;
}

String getDeviceTypeDescription(int typeCode) {
  final protocol = typeCode & 0xFF;

  if (protocol == 0x01) {
    return DaliDeviceType.types[typeCode] ??
        'DALI Device (0x${typeCode.toRadixString(16)})';
  } else if (protocol == 0x02) {
    return DigidimDeviceType.types[typeCode] ??
        'Digidim Device (0x${typeCode.toRadixString(16)})';
  } else if (protocol == 0x04) {
    return ImagineDeviceType.types[typeCode] ??
        'Imagine Device (0x${typeCode.toRadixString(16)})';
  } else if (protocol == 0x08) {
    return DmxDeviceType.types[typeCode] ??
        'DMX Device (0x${typeCode.toRadixString(16)})';
  } else if (typeCode == 4818434) {
    return '498 – Relay Unit (8 channel relay) DALI';
  } else if (typeCode == 3217410 ||
      typeCode == 3220738 ||
      typeCode == 3282690) {
    return 'Multisensor';
  } else if (typeCode == 1537) {
    return 'LED Unit';
  } else if (typeCode == 1265666) {
    return 'Button 135';
  } else if (typeCode == 1) {
    return 'Fluorescent Lamps';
  } else if (typeCode == 1793) {
    return 'Switching function (Relay)';
  } else if (typeCode == 1226903554) {
    return 'DDP Device';
  }

  return typeCode.toRadixString(16);
}

class DaliDeviceType {
  static const Map<int, String> types = {
    0x0001: 'Fluorescent Lamps',
    0x0101: 'Self-contained emergency lighting',
    0x0201: 'Discharge lamps (excluding fluorescent lamps)',
    0x0301: 'Low voltage halogen lamps',
    0x0401: 'Incandescent lamps',
    0x0501: 'Conversion into D.C. voltage (IEC 60929)',
    0x0601: 'LED modules',
    0x0701: 'Switching function (i.e., Relay)',
    0x0801: 'Colour control',
    0x0901: 'Sequencer',
    // 0x0A01 undefined
    // 0x0B01 - 0xFE01 undefined
  };
}

class DigidimDeviceType {
  static const Map<int, String> types = {
    0x00100802: '100 – Rotary',
    0x00110702: '110 – Single Sider',
    0x00111402: '111 – Double Sider',
    0x00121302: '121 – 2 Button On/Off + IR',
    0x00122002: '122 – 2 Button Modifier + IR',
    0x00124402: '124 – 5 Button + IR',
    0x00125102: '125 – 7 Button + IR',
    0x00126802: '126 – 8 Button + IR',
    0x00131202: '131 – 2 Button On/Off + IR',
    0x00132902: '132 – 2 Button Modifier + IR',
    0x00134302: '134 – 5 Button + IR',
    0x00135002: '135 – 7 Button + IR',
    0x00136702: '136 – 8 Button + IR',
    0x00137402: '137 – 4 Button + IR',
    0x00170102: '170 – IR Receiver',
    0x00312502: '312 – Multisensor',
    0x00410802: '410 – Ballast (1-10V Converter)',
    0x00416002: '416S – 16A Dimmer',
    0x00425202: '425S – 25A Dimmer',
    0x00444302: '444 – Mini Input Unit',
    0x00450402: '450 – 800W Dimmer',
    0x00452802: '452 – 1000W Universal Dimmer',
    0x00455902: '455 – 500W Thruster Dimmer',
    0x00458002: '458/DIMB – 8-Channel Dimmer',
    0x74458102: '459/CTRB – 8-Ch Ballast Controller',
    0x04458302: '459/SWB – 8-Ch Relay Module',
    0x00460302: '460 – DALI-to-SDIM Converter',
    0x00472602: '472 – Din Rail 1-10V/DS/8 Converter',
    0x00474002: '474 – 4-Ch Ballast (Output Unit)',
    0x00474102: '474 – 4-Ch Ballast (Relay Unit)',
    0x00490002: '490 – Blinds Unit',
    0x00494802: '494 – Relay Unit',
    0x00496602: '498 – Relay Unit',
    0x00804502: '804 – Digidim 4',
    0x00824002: '924 – LCD TouchPanel',
    0x00935602: '935 – Scene Commander (6 Buttons)',
    0x00939402: '939 – Scene Commander (10 Buttons)',
    0x00942402: '942 – Analogue Input Unit',
    0x00458602: '459/CPT4 – 4-Ch Options Module',
    0x80142401: '142 – 2 Button (DALI‑2)',
    0x80144801: '144 – 4 Button (DALI‑2)',
    0x80146201: '146 – 6 Button (DALI‑2)',
    0x80148601: '148 – 8 Button (DALI‑2)',
    0x80135601: '135D2 – 7 Button (DALI‑2)',
    0x81135501: '135BD2 – 7 Button (DALI‑2)',
    0x82135401: '135WD2 – 7 Button (DALI‑2)',
    0x00311802: 'Ceiling PIR detector 311',
    0x00313202: 'Microwave detector 313',
    0x00314902: 'Tilting microwave detector 314',
    0x00315602: 'Multisensor 315',
    0x00317002: 'High bay detector 317',
    0x00318702: 'Wall Mounted PIR 318',
    0x00319402: 'High bay spot detector 319',
    0x00320002: 'Ceiling PIR detector 320',
    0x00321702: 'Multisensor 321',
    0x00322402: 'High bay detector 322',
    0x00329302: 'External Light Sensor 329',
    0x00434402: 'EnOcean Gateway',
    0x00441202: '441 (Sensor Interface)',
    0x00445002: 'Switch Interface Unit 445',
    0x01290502: 'ILLUSTRIS 290',
    0x02290402: 'ILLUSTRIS 290',
    0x05745901: 'Steinel Multisensor Dual HF',
    0x05748001: 'Steinel Multisensor HF 360',
    0x05749701: 'Steinel Multisensor IR Quattro HD',
    0x06624601: 'Steinel Multisensor IS 3360 MX',
    0x06626001: 'Steinel Multisensor IS 345 MX',
    0x11191202: 'ILLUSTRIS 191B',
    0x11192902: 'ILLUSTRIS 192B',
    0x11193602: 'ILLUSTRIS 193B',
    0x12191102: 'ILLUSTRIS 191W',
    0x12192802: 'ILLUSTRIS 192W',
    0x12193502: 'ILLUSTRIS 193W',
    0x21191902: 'ILLUSTRIS 191B',
    0x21192602: 'ILLUSTRIS 192B',
    0x21193302: 'ILLUSTRIS 193B',
    0x22191802: 'ILLUSTRIS 191W',
    0x22192502: 'ILLUSTRIS 192W',
    0x22193202: 'ILLUSTRIS 193W',
    0x49210302: 'EnOcean Button Panel',
    0x49211002: 'EnOcean Button Panel',
    0x80000001: 'DALI-2 Control Device',
    0x80131801: 'Button 131D2',
    0x80132501: 'Button 132D',
    0x80134901: 'Button 134D2',
    0x80136301: 'Button 136D2',
    0x80137001: 'Button 137D2',
    0x80320601: 'Ceiling PIR detector 320D2',
    0x80321301: 'Multisensor 321D2',
    0x80322001: 'High bay detector 322D2',
    0x80441801: '441D2 (Sensor Interface)',
    0x80444901: 'Mini Input Unit 444D2',
    0x81131701: 'Button 131BD2',
    0x81132401: 'Button 132BD',
    0x81134801: 'Button 134BD2',
    0x81136201: 'Button 136BD2',
    0x81137901: 'Button 137BD2',
    0x81320501: 'Ceiling PIR detector 320D2',
    0x81321201: 'Multisensor 321D2',
    0x81322901: 'High bay detector 322D2',
    0x82131601: 'Button 131WD2',
    0x82132301: 'Button 132WD',
    0x82134701: 'Button 134WD2',
    0x82136101: 'Button 136WD2',
    0x82137801: 'Button 137D2',
    0x82320401: 'Ceiling PIR detector 320D2',
    0x82321101: 'Multisensor 321D2',
    0x83320301: 'Ceiling PIR detector 320D2',
    0x83321001: 'Multisensor 321D2',
  };
}

class ImagineDeviceType {
  static const Map<int, String> types = {
    0x00000004: 'No device present',
    0x0000F104: '474 – 4 Channel Ballast Controller - Relay Unit',
    0x0000F204: '474 – 4 Channel Ballast Controller - Output Unit',
    0x0000F304: '458/SW8 – 8-Channel Relay Module',
    0x0000F404: '458/CTR8 – 8-Channel Ballast Controller',
    0x0000F504: '458/OPT4 – Options Module',
    0x0000F604: '498 – 8-Channel Relay Unit',
    0x0000F704: '458/DIM8 – 8-Channel Dimmer',
    0x0000F804: 'HES92060 – Sine Wave Dimmer',
    0x0000F904: 'Ambience4 Dimmer',
    0x0000FA04: 'HES92020 – SCR Dimmer',
    0x0000FB04: 'HES98020 – Output Unit',
    0x0000FC04: 'HES92220 – Transistor Dimmer',
    0x0000FD04: 'HES92082 – 2 Channel Output Unit',
    0x0000FE04: 'HES98180-98291 – Relay Unit',
    0x0000FF04: 'Dimmer (old style, type undefined)',
  };
}

class DmxDeviceType {
  static const Map<int, String> types = {
    0x00000008: 'DMX No device present',
    0x00000108: 'DMX Channel In',
    0x00000208: 'DMX Channel Out',
  };
}

class DigidimKeyType {
  static const Map<int, String> types = {
    0x00000001: 'SinglePress',
    0x00000002: 'TimedPress',
    0x00000003: 'ToggleSolo',
    0x00000004: 'ToggleBlock',
    0x00000005: 'TouchDimBlock',
    0x00000006: 'TouchDimSolo',
    0x00000007: 'Modifier',
    0x00000008: 'EdgeMode',
    0x00000009: 'Slider',
    0x0000000A: 'AnalogueInput',
    0x0000000B: 'Rotary',
    0x0000000C: 'PIR',
    0x0000000D: 'ConstantLight',
    0x0000000E: 'SliderInputUnit',
  };
}

/// Returns the number of buttons for the given [typeCode] if available.
int? getButtonCountForTypeCode(int typeCode) =>
    buttonCountForTypeCode(typeCode);
