import 'currency_api.dart';
import 'mock_currency_api.dart';
import 'remote_currency_api.dart';

CurrencyApi get currencyApi => _currencyApi;
CurrencyApi _currencyApi = MockCurrencyApi();

enum CurrencyApiMode { mock, api }

void useMockCurrencyApi() {
  _currencyApi = MockCurrencyApi();
}

void useRemoteCurrencyApi({
  required String baseUrl,
  Duration timeout = const Duration(seconds: 5),
}) {
  _currencyApi = RemoteCurrencyApi(baseUrl: baseUrl, timeout: timeout);
}

CurrencyApiMode configureCurrencyApi({
  required String modeText,
  String? baseUrl,
  Duration timeout = const Duration(seconds: 5),
}) {
  final mode = _parseMode(modeText);
  switch (mode) {
    case CurrencyApiMode.mock:
      useMockCurrencyApi();
      return CurrencyApiMode.mock;
    case CurrencyApiMode.api:
      final normalizedBaseUrl = (baseUrl ?? '').trim();
      if (normalizedBaseUrl.isEmpty) {
        throw ArgumentError(
          'CURRENCY_API_BASE_URL is required when CURRENCY_API_MODE is "api".',
        );
      }
      useRemoteCurrencyApi(baseUrl: normalizedBaseUrl, timeout: timeout);
      return CurrencyApiMode.api;
  }
}

CurrencyApiMode _parseMode(String modeText) {
  final normalized = modeText.trim().toLowerCase();
  if (normalized.isEmpty || normalized == 'mock') {
    return CurrencyApiMode.mock;
  }
  if (normalized == 'api' || normalized == 'remote') {
    return CurrencyApiMode.api;
  }
  throw ArgumentError('Unsupported CURRENCY_API_MODE: $modeText');
}
