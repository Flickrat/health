/// BLE GATT service/characteristic UUIDs and Bonjour services extracted
/// directly from Lynio.app and its bundled lynio-wearos.apk.
class LynioBleConstants {
  LynioBleConstants._();

  // Lynio custom Wear OS Link GATT Service & Characteristics
  static const String lynioServiceUuid =
      'E7A20001-9B4C-4F2A-8D6E-1C3A5B7D9F00';
  static const String lynioTxCharUuid =
      'E7A20002-9B4C-4F2A-8D6E-1C3A5B7D9F00';
  static const String lynioRxCharUuid =
      'E7A20003-9B4C-4F2A-8D6E-1C3A5B7D9F00';
  static const String lynioBulkTxCharUuid =
      'E7A20010-9B4C-4F2A-8D6E-1C3A5B7D9F00';
  static const String lynioBulkRxCharUuid =
      'E7A20011-9B4C-4F2A-8D6E-1C3A5B7D9F00';
  static const String lynioControlCharUuid =
      'E7A20012-9B4C-4F2A-8D6E-1C3A5B7D9F00';
  static const String lynioStatusCharUuid =
      'E7A20013-9B4C-4F2A-8D6E-1C3A5B7D9F00';

  // Apple Notification Center Service (ANCS)
  static const String ancsServiceUuid =
      '7905F431-B5CE-4E99-A40F-4B1E122D00D0';
  static const String ancsNotificationSourceUuid =
      '9FBF120D-6301-42D9-8C58-25E699A21DBD';
  static const String ancsControlPointUuid =
      '69D1D8F3-45E1-49A8-9821-9BBDFDAAD9D9';
  static const String ancsDataSourceUuid =
      '22EAC6E9-24D6-4BB5-BE44-B36ACE7C7BFB';

  // Apple Media Service (AMS)
  static const String amsServiceUuid =
      '89D3502B-0F36-433A-8EF4-C502AD55F8DC';
  static const String amsRemoteCommandUuid =
      '9B3C81D8-57B1-4A8A-B8DF-0E56F7CA51C2';
  static const String amsEntityUpdateUuid =
      '2F7CABCE-808D-411F-9A0C-BB92BA96C102';
  static const String amsEntityAttributeUuid =
      'C6B2F38C-23AB-46D8-A6AB-A3A870BBD5D7';

  // Wireless ADB TLS Bonjour Services (used for Wear OS companion APK install)
  static const String adbTlsPairingService = '_adb-tls-pairing._tcp';
  static const String adbTlsConnectService = '_adb-tls-connect._tcp';
}
