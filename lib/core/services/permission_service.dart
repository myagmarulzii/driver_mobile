import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  static Future<bool> requestLocationAlwaysPermission() async {
    final status = await Permission.locationAlways.request();
    return status.isGranted;
  }

  static Future<bool> requestBluetoothPermissions() async {
    if (await Permission.bluetooth.isGranted) {
      return true;
    }

    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
    ].request();

    return statuses.values.every((status) =>
      status.isGranted || status.isLimited
    );
  }

  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<void> requestInitialPermissions() async {
    // Request critical permissions at startup
    await requestLocationPermission();
    await requestBluetoothPermissions();
    await requestNotificationPermission();
  }

  static Future<bool> checkLocationPermission() async {
    return await Permission.location.isGranted;
  }

  static Future<bool> checkBluetoothPermission() async {
    return await Permission.bluetooth.isGranted;
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
