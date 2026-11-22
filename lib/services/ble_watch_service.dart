import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../core/ble_constants.dart';

class DiscoveredWatchDevice {
  const DiscoveredWatchDevice({
    required this.id,
    required this.name,
    required this.rssi,
    required this.advertisesLynio,
    this.bluetoothDevice,
  });

  final String id;
  final String name;
  final int rssi;
  final bool advertisesLynio;
  final BluetoothDevice? bluetoothDevice;
}

/// Real BLE scanner/connector targeting Lynio's Wear OS GATT service
/// (`E7A20001-9B4C-4F2A-8D6E-1C3A5B7D9F00`) with graceful fallback on
/// simulators or when Bluetooth is unavailable.
class BleWatchService {
  StreamSubscription<List<ScanResult>>? _scanSub;
  BluetoothDevice? _connectedDevice;

  Future<bool> isBluetoothAvailable() async {
    try {
      if (kIsWeb) return false;
      final supported = await FlutterBluePlus.isSupported;
      if (!supported) return false;
      final state = await FlutterBluePlus.adapterState.first
          .timeout(const Duration(seconds: 2));
      return state == BluetoothAdapterState.on;
    } catch (_) {
      return false;
    }
  }

  Future<void> startScan({
    required void Function(List<DiscoveredWatchDevice> devices) onUpdate,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    await stopScan();
    final found = <String, DiscoveredWatchDevice>{};

    final available = await isBluetoothAvailable();
    if (!available) {
      return;
    }

    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        final name = r.device.platformName.isNotEmpty
            ? r.device.platformName
            : r.advertisementData.advName;
        final serviceUuids = r.advertisementData.serviceUuids
            .map((g) => g.str.toUpperCase())
            .toSet();
        final isLynio = serviceUuids
            .contains(LynioBleConstants.lynioServiceUuid.toUpperCase());

        if (name.isEmpty && !isLynio) continue;
        found[r.device.remoteId.str] = DiscoveredWatchDevice(
          id: r.device.remoteId.str,
          name: name.isNotEmpty ? name : 'Wear OS Watch',
          rssi: r.rssi,
          advertisesLynio: isLynio,
          bluetoothDevice: r.device,
        );
      }
      final list = found.values.toList()
        ..sort((a, b) {
          if (a.advertisesLynio != b.advertisesLynio) {
            return a.advertisesLynio ? -1 : 1;
          }
          return b.rssi.compareTo(a.rssi);
        });
      onUpdate(list);
    });

    await FlutterBluePlus.startScan(timeout: timeout);
  }

  Future<void> stopScan() async {
    await _scanSub?.cancel();
    _scanSub = null;
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}
  }

  Future<bool> connect(DiscoveredWatchDevice device) async {
    final bt = device.bluetoothDevice;
    if (bt == null) return false;
    try {
      await bt.connect(
        license: License.nonprofit,
        timeout: const Duration(seconds: 10),
      );
      _connectedDevice = bt;
      await bt.discoverServices();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await _connectedDevice?.disconnect();
    } catch (_) {}
    _connectedDevice = null;
  }
}
