// lib/services/remote_config_service.dart

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Thêm import
import 'package:mincloset/providers/service_providers.dart'; // Thêm import
import 'package:mincloset/services/secure_storage_service.dart';
import 'package:mincloset/utils/logger.dart';

enum InitializationStatus {
  success,
  failedNoNetwork,
  failedGeneric
}

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig;
  final SecureStorageService _secureStorage;
  final Connectivity _connectivity;
  final Ref _ref; // Thêm Ref vào dependency

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  RemoteConfigService({
    required FirebaseRemoteConfig remoteConfig,
    required SecureStorageService secureStorage,
    required Connectivity connectivity,
    required Ref ref, // Thêm Ref vào constructor
  })  : _remoteConfig = remoteConfig,
        _secureStorage = secureStorage,
        _connectivity = connectivity,
        _ref = ref;

  // Hàm này sẽ được gọi một lần duy nhất khi ứng dụng khởi động
  Future<void> initializeAndFetchKeys() async {
    final geminiKey = await _secureStorage.read(SecureStorageKeys.geminiApiKey);

    if (geminiKey != null && geminiKey.isNotEmpty) {
      logger.i('API keys đã có sẵn trong secure storage.');
      // Bật "công tắc" vì key đã sẵn sàng
      _ref.read(apiKeysReadyProvider.notifier).state = true;
      return;
    }

    logger.w('Chưa có API keys. Đang thử lấy từ Remote Config...');
    final status = await _fetchAndStoreKeys();

    // Nếu lần đầu thất bại do không có mạng, hãy bắt đầu lắng nghe
    if (status == InitializationStatus.failedNoNetwork) {
      listenForConnectivityAndRetry();
    }
  }

  // Tách logic fetch ra một hàm riêng
  Future<InitializationStatus> _fetchAndStoreKeys() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      logger.e('Không có mạng. Không thể lấy API keys.');
      return InitializationStatus.failedNoNetwork;
    }

    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: Duration.zero,
      ));
      await _remoteConfig.fetchAndActivate();

      final fetchedGeminiKey = _remoteConfig.getString(SecureStorageKeys.geminiApiKey);
      final fetchedWeatherKey = _remoteConfig.getString(SecureStorageKeys.openWeatherApiKey);
      final fetchedSentryDsn = _remoteConfig.getString(SecureStorageKeys.sentryDsn);

      if (fetchedGeminiKey.isNotEmpty) await _secureStorage.write(SecureStorageKeys.geminiApiKey, fetchedGeminiKey);
      if (fetchedWeatherKey.isNotEmpty) await _secureStorage.write(SecureStorageKeys.openWeatherApiKey, fetchedWeatherKey);
      if (fetchedSentryDsn.isNotEmpty) await _secureStorage.write(SecureStorageKeys.sentryDsn, fetchedSentryDsn);

      logger.i('Lấy và lưu trữ API keys từ Remote Config thành công.');
      // Bật "công tắc" vì key đã sẵn sàng
      _ref.read(apiKeysReadyProvider.notifier).state = true;
      return InitializationStatus.success;

    } catch (e) {
      logger.e('Lấy keys từ Remote Config thất bại', error: e);
      return InitializationStatus.failedGeneric;
    }
  }

  // Hàm lắng nghe mạng giờ sẽ không cần callback
  void listenForConnectivityAndRetry() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) async {
      final bool areKeysReady = _ref.read(apiKeysReadyProvider);
      
      // Chỉ thử lại nếu key chưa sẵn sàng và có kết nối mạng
      if (!areKeysReady && !results.contains(ConnectivityResult.none)) {
        logger.i('Có mạng trở lại. Đang thử lấy lại keys...');
        final status = await _fetchAndStoreKeys();
        
        // Nếu thành công, hủy việc lắng nghe
        if (status == InitializationStatus.success) {
          logger.i('Lấy lại keys thành công. Dừng lắng nghe mạng.');
          _connectivitySubscription?.cancel();
          _connectivitySubscription = null;
        }
      }
    });
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}