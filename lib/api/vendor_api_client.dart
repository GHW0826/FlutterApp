import 'mock_vendor_api.dart';
import 'remote_vendor_api.dart';
import 'vendor_api.dart';

VendorApi get vendorApi => _vendorApi;
VendorApi _vendorApi = MockVendorApi();

enum VendorApiMode { mock, api }

void useMockVendorApi() {
  _vendorApi = MockVendorApi();
}

void useRemoteVendorApi({
  required String baseUrl,
  Duration timeout = const Duration(seconds: 5),
  String authToken = '',
}) {
  _vendorApi = RemoteVendorApi(
    baseUrl: baseUrl,
    timeout: timeout,
    authToken: authToken,
  );
}

VendorApiMode configureVendorApi({
  required String modeText,
  String? baseUrl,
  Duration timeout = const Duration(seconds: 5),
  String authToken = '',
}) {
  final mode = _parseMode(modeText);
  switch (mode) {
    case VendorApiMode.mock:
      useMockVendorApi();
      return VendorApiMode.mock;
    case VendorApiMode.api:
      final normalizedBaseUrl = (baseUrl ?? '').trim();
      if (normalizedBaseUrl.isEmpty) {
        throw ArgumentError(
          'VENDOR_API_BASE_URL is required when VENDOR_API_MODE is "api".',
        );
      }
      useRemoteVendorApi(
        baseUrl: normalizedBaseUrl,
        timeout: timeout,
        authToken: authToken,
      );
      return VendorApiMode.api;
  }
}

VendorApiMode _parseMode(String modeText) {
  final normalized = modeText.trim().toLowerCase();
  if (normalized.isEmpty || normalized == 'mock') {
    return VendorApiMode.mock;
  }
  if (normalized == 'api' || normalized == 'remote') {
    return VendorApiMode.api;
  }
  throw ArgumentError('Unsupported VENDOR_API_MODE: $modeText');
}
