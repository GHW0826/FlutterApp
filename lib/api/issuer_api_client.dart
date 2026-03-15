import 'issuer_api.dart';
import 'mock_issuer_api.dart';
import 'remote_issuer_api.dart';

IssuerApi get issuerApi => _issuerApi;
IssuerApi _issuerApi = MockIssuerApi();

enum IssuerApiMode { mock, api }

void useMockIssuerApi() {
  _issuerApi = MockIssuerApi();
}

void useRemoteIssuerApi({
  required String baseUrl,
  Duration timeout = const Duration(seconds: 5),
}) {
  _issuerApi = RemoteIssuerApi(baseUrl: baseUrl, timeout: timeout);
}

IssuerApiMode configureIssuerApi({
  required String modeText,
  String? baseUrl,
  Duration timeout = const Duration(seconds: 5),
}) {
  final mode = _parseMode(modeText);
  switch (mode) {
    case IssuerApiMode.mock:
      useMockIssuerApi();
      return IssuerApiMode.mock;
    case IssuerApiMode.api:
      final normalizedBaseUrl = (baseUrl ?? '').trim();
      if (normalizedBaseUrl.isEmpty) {
        throw ArgumentError(
          'ISSUER_API_BASE_URL is required when ISSUER_API_MODE is "api".',
        );
      }
      useRemoteIssuerApi(baseUrl: normalizedBaseUrl, timeout: timeout);
      return IssuerApiMode.api;
  }
}

IssuerApiMode _parseMode(String modeText) {
  final normalized = modeText.trim().toLowerCase();
  if (normalized.isEmpty || normalized == 'mock') {
    return IssuerApiMode.mock;
  }
  if (normalized == 'api' || normalized == 'remote') {
    return IssuerApiMode.api;
  }
  throw ArgumentError('Unsupported ISSUER_API_MODE: $modeText');
}
