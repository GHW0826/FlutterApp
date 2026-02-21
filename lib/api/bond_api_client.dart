import 'bond_api.dart';
import 'mock_bond_api.dart';
import 'remote_bond_api.dart';

/// Bond API client selector (Mock / Remote).
/// For remote server usage: bondApi = RemoteBondApi(baseUrl: 'https://api.example.com');
BondApi get bondApi => _bondApi;
BondApi _bondApi = MockBondApi();

enum BondApiMode {
  mock,
  api,
}

/// Use mock API (default).
void useMockBondApi() {
  _bondApi = MockBondApi();
}

/// Use remote server API.
void useRemoteBondApi({required String baseUrl, Duration timeout = const Duration(seconds: 5)}) {
  _bondApi = RemoteBondApi(baseUrl: baseUrl, timeout: timeout);
}

/// Configure Bond API by app run mode.
///
/// [modeText] supports:
/// - `mock` (default)
/// - `api` or `remote`
///
/// When mode is `api`/`remote`, [baseUrl] must not be empty.
BondApiMode configureBondApi({
  required String modeText,
  String? baseUrl,
  Duration timeout = const Duration(seconds: 5),
}) {
  final mode = _parseMode(modeText);
  switch (mode) {
    case BondApiMode.mock:
      useMockBondApi();
      return BondApiMode.mock;
    case BondApiMode.api:
      final normalizedBaseUrl = (baseUrl ?? '').trim();
      if (normalizedBaseUrl.isEmpty) {
        throw ArgumentError(
          'BOND_API_BASE_URL is required when BOND_API_MODE is "api".',
        );
      }
      useRemoteBondApi(baseUrl: normalizedBaseUrl, timeout: timeout);
      return BondApiMode.api;
  }
}

BondApiMode _parseMode(String modeText) {
  final normalized = modeText.trim().toLowerCase();
  if (normalized.isEmpty || normalized == 'mock') {
    return BondApiMode.mock;
  }
  if (normalized == 'api' || normalized == 'remote') {
    return BondApiMode.api;
  }
  throw ArgumentError('Unsupported BOND_API_MODE: $modeText');
}
