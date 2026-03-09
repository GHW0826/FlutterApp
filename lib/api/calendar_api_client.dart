import 'calendar_api.dart';
import 'mock_calendar_api.dart';
import 'remote_calendar_api.dart';

CalendarApi get calendarApi => _calendarApi;
CalendarApi _calendarApi = MockCalendarApi();

enum CalendarApiMode { mock, api }

void useMockCalendarApi() {
  _calendarApi = MockCalendarApi();
}

void useRemoteCalendarApi({
  required String baseUrl,
  Duration timeout = const Duration(seconds: 5),
}) {
  _calendarApi = RemoteCalendarApi(baseUrl: baseUrl, timeout: timeout);
}

CalendarApiMode configureCalendarApi({
  required String modeText,
  String? baseUrl,
  Duration timeout = const Duration(seconds: 5),
}) {
  final mode = _parseMode(modeText);
  switch (mode) {
    case CalendarApiMode.mock:
      useMockCalendarApi();
      return CalendarApiMode.mock;
    case CalendarApiMode.api:
      final normalizedBaseUrl = (baseUrl ?? '').trim();
      if (normalizedBaseUrl.isEmpty) {
        throw ArgumentError(
          'CALENDAR_API_BASE_URL is required when CALENDAR_API_MODE is "api".',
        );
      }
      useRemoteCalendarApi(baseUrl: normalizedBaseUrl, timeout: timeout);
      return CalendarApiMode.api;
  }
}

CalendarApiMode _parseMode(String modeText) {
  final normalized = modeText.trim().toLowerCase();
  if (normalized.isEmpty || normalized == 'mock') {
    return CalendarApiMode.mock;
  }
  if (normalized == 'api' || normalized == 'remote') {
    return CalendarApiMode.api;
  }
  throw ArgumentError('Unsupported CALENDAR_API_MODE: $modeText');
}
