import 'country_api.dart';
import 'mock_country_api.dart';
import 'remote_country_api.dart';

CountryApi get countryApi => _countryApi;
CountryApi _countryApi = MockCountryApi();

enum CountryApiMode { mock, api }

void useMockCountryApi() {
  _countryApi = MockCountryApi();
}

void useRemoteCountryApi({
  required String baseUrl,
  Duration timeout = const Duration(seconds: 5),
}) {
  _countryApi = RemoteCountryApi(baseUrl: baseUrl, timeout: timeout);
}

CountryApiMode configureCountryApi({
  required String modeText,
  String? baseUrl,
  Duration timeout = const Duration(seconds: 5),
}) {
  final mode = _parseMode(modeText);
  switch (mode) {
    case CountryApiMode.mock:
      useMockCountryApi();
      return CountryApiMode.mock;
    case CountryApiMode.api:
      final normalizedBaseUrl = (baseUrl ?? '').trim();
      if (normalizedBaseUrl.isEmpty) {
        throw ArgumentError(
          'COUNTRY_API_BASE_URL is required when COUNTRY_API_MODE is "api".',
        );
      }
      useRemoteCountryApi(baseUrl: normalizedBaseUrl, timeout: timeout);
      return CountryApiMode.api;
  }
}

CountryApiMode _parseMode(String modeText) {
  final normalized = modeText.trim().toLowerCase();
  if (normalized.isEmpty || normalized == 'mock') {
    return CountryApiMode.mock;
  }
  if (normalized == 'api' || normalized == 'remote') {
    return CountryApiMode.api;
  }
  throw ArgumentError('Unsupported COUNTRY_API_MODE: $modeText');
}
