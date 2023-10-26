import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/services/connectivity_service.dart';

class ConnectivityProvider extends ChangeNotifier {
  final ConnectivityService _connectivityService = ConnectivityService();
  ConnectivityResult _connectivityResult = ConnectivityResult.none;

  ConnectivityProvider() {
    _connectivityService.connectivityStream.listen((result) {
      _connectivityResult = result;
      notifyListeners();
    });
  }

  ConnectivityResult get connectivityResult => _connectivityResult;
}
