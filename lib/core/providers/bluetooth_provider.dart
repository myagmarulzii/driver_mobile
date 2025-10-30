import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum BluetoothConnectionStatus {
  disconnected,
  discovering,
  pairing,
  connected,
  error
}

class BluetoothProvider with ChangeNotifier {
  BluetoothConnectionStatus _status = BluetoothConnectionStatus.disconnected;
  BluetoothDevice? _pairedDevice;
  String? _pairedUserId;
  List<ScanResult> _discoveredDevices = [];
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;

  BluetoothConnectionStatus get status => _status;
  BluetoothDevice? get pairedDevice => _pairedDevice;
  String? get pairedUserId => _pairedUserId;
  List<ScanResult> get discoveredDevices => _discoveredDevices;
  bool get isConnected => _status == BluetoothConnectionStatus.connected;

  // Start scanning for nearby devices
  Future<void> startScanning() async {
    try {
      _status = BluetoothConnectionStatus.discovering;
      _discoveredDevices = [];
      notifyListeners();

      // Check if Bluetooth is available
      if (await FlutterBluePlus.isSupported == false) {
        debugPrint('Bluetooth not supported by this device');
        _status = BluetoothConnectionStatus.error;
        notifyListeners();
        return;
      }

      // Start scanning
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        androidUsesFineLocation: true,
      );

      // Listen to scan results
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        _discoveredDevices = results;
        notifyListeners();
      });

      // Auto-stop after timeout
      Future.delayed(const Duration(seconds: 10), () {
        stopScanning();
      });
    } catch (e) {
      debugPrint('Bluetooth scan error: $e');
      _status = BluetoothConnectionStatus.error;
      notifyListeners();
    }
  }

  // Stop scanning
  Future<void> stopScanning() async {
    try {
      await FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
      _scanSubscription = null;

      if (_status == BluetoothConnectionStatus.discovering) {
        _status = BluetoothConnectionStatus.disconnected;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Stop scanning error: $e');
    }
  }

  // Connect to a device
  Future<bool> connectToDevice(BluetoothDevice device, String userId) async {
    try {
      _status = BluetoothConnectionStatus.pairing;
      notifyListeners();

      // Stop scanning before connecting
      await stopScanning();

      // Connect to device
      await device.connect(
        timeout: const Duration(seconds: 10),
        autoConnect: false,
      );

      // Listen to connection state
      _connectionSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.connected) {
          _status = BluetoothConnectionStatus.connected;
          _pairedDevice = device;
          _pairedUserId = userId;
        } else {
          _status = BluetoothConnectionStatus.disconnected;
          _pairedDevice = null;
          _pairedUserId = null;
        }
        notifyListeners();
      });

      return true;
    } catch (e) {
      debugPrint('Connection error: $e');
      _status = BluetoothConnectionStatus.error;
      notifyListeners();
      return false;
    }
  }

  // Disconnect from device
  Future<void> disconnect() async {
    try {
      if (_pairedDevice != null) {
        await _pairedDevice!.disconnect();
        await _connectionSubscription?.cancel();
        _connectionSubscription = null;
      }

      _pairedDevice = null;
      _pairedUserId = null;
      _status = BluetoothConnectionStatus.disconnected;
      notifyListeners();
    } catch (e) {
      debugPrint('Disconnect error: $e');
    }
  }

  // Send data to paired device
  Future<bool> sendData(String data) async {
    if (_pairedDevice == null || !isConnected) {
      debugPrint('No device connected');
      return false;
    }

    try {
      // Discover services
      final services = await _pairedDevice!.discoverServices();

      // Find a writable characteristic
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            await characteristic.write(data.codeUnits);
            return true;
          }
        }
      }

      debugPrint('No writable characteristic found');
      return false;
    } catch (e) {
      debugPrint('Send data error: $e');
      return false;
    }
  }

  // Listen for data from paired device
  Stream<String>? listenForData() {
    if (_pairedDevice == null || !isConnected) {
      return null;
    }

    return _pairedDevice!.connectionState.asyncMap((state) async {
      if (state != BluetoothConnectionState.connected) {
        return '';
      }

      final services = await _pairedDevice!.discoverServices();

      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.notify) {
            await characteristic.setNotifyValue(true);
            return characteristic.lastValueStream.map((value) {
              return String.fromCharCodes(value);
            }).first;
          }
        }
      }

      return '';
    }).where((data) => data.isNotEmpty);
  }

  // Check Bluetooth state
  Future<bool> isBluetoothEnabled() async {
    try {
      final adapterState = await FlutterBluePlus.adapterState.first;
      return adapterState == BluetoothAdapterState.on;
    } catch (e) {
      debugPrint('Bluetooth state check error: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    disconnect();
    super.dispose();
  }
}
