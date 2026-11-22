import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:watch_connectivity/watch_connectivity.dart';

class AppleWatchStatus {
  const AppleWatchStatus({
    required this.supported,
    required this.paired,
    required this.reachable,
  });

  final bool supported;
  final bool paired;
  final bool reachable;
}

/// Bridges the Flutter iOS app with the native watchOS companion target
/// (`ios/LynioWatch`) using Apple's `WatchConnectivity` (`WCSession`).
class AppleWatchService {
  WatchConnectivity? _watch;
  StreamSubscription<Map<String, dynamic>>? _messageSub;
  StreamSubscription<Map<String, dynamic>>? _contextSub;

  WatchConnectivity? _ensureClient() {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return null;
    try {
      _watch ??= WatchConnectivity();
      return _watch;
    } catch (_) {
      return null;
    }
  }

  Future<AppleWatchStatus> checkStatus() async {
    final client = _ensureClient();
    if (client == null) {
      return const AppleWatchStatus(
        supported: false,
        paired: false,
        reachable: false,
      );
    }
    try {
      final supported = await client.isSupported;
      if (!supported) {
        return const AppleWatchStatus(
          supported: false,
          paired: false,
          reachable: false,
        );
      }
      final paired = await client.isPaired;
      final reachable = await client.isReachable;
      return AppleWatchStatus(
        supported: supported,
        paired: paired,
        reachable: reachable,
      );
    } catch (_) {
      return const AppleWatchStatus(
        supported: false,
        paired: false,
        reachable: false,
      );
    }
  }

  void listen({
    required void Function(Map<String, dynamic> payload) onMessage,
  }) {
    final client = _ensureClient();
    if (client == null) return;
    _messageSub?.cancel();
    _contextSub?.cancel();
    try {
      _messageSub = client.messageStream.listen(onMessage);
      _contextSub = client.contextStream.listen(onMessage);
    } catch (_) {}
  }

  Future<bool> sendMessage(Map<String, dynamic> message) async {
    final client = _ensureClient();
    if (client == null) return false;
    try {
      if (await client.isReachable) {
        await client.sendMessage(message);
        return true;
      }
      await client.updateApplicationContext(message);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateContext(Map<String, dynamic> context) async {
    final client = _ensureClient();
    if (client == null) return false;
    try {
      await client.updateApplicationContext(context);
      return true;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _messageSub?.cancel();
    _contextSub?.cancel();
  }
}
