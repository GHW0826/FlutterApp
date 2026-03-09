import 'package:flutter/material.dart';
import 'api/calendar_api_client.dart';
import 'api/bond_api_client.dart';
import 'api/country_api_client.dart';
import 'api/currency_api_client.dart';
import 'api/issuer_api_client.dart';
import 'api/vendor_api_client.dart';
import 'screens/main_screen.dart';

void main() {
  const bondApiMode = String.fromEnvironment(
    'BOND_API_MODE',
    defaultValue: 'api',
  );
  const bondApiBaseUrl = String.fromEnvironment(
    'BOND_API_BASE_URL',
    defaultValue: 'http://localhost:8888',
  );
  const vendorApiMode = String.fromEnvironment(
    'VENDOR_API_MODE',
    defaultValue: bondApiMode,
  );
  const vendorApiBaseUrl = String.fromEnvironment(
    'VENDOR_API_BASE_URL',
    defaultValue: bondApiBaseUrl,
  );
  const vendorApiAuthToken = String.fromEnvironment(
    'VENDOR_API_AUTH_TOKEN',
    defaultValue: '',
  );
  const calendarApiMode = String.fromEnvironment(
    'CALENDAR_API_MODE',
    defaultValue: vendorApiMode,
  );
  const calendarApiBaseUrl = String.fromEnvironment(
    'CALENDAR_API_BASE_URL',
    defaultValue: vendorApiBaseUrl,
  );
  const countryApiMode = String.fromEnvironment(
    'COUNTRY_API_MODE',
    defaultValue: calendarApiMode,
  );
  const countryApiBaseUrl = String.fromEnvironment(
    'COUNTRY_API_BASE_URL',
    defaultValue: calendarApiBaseUrl,
  );
  const currencyApiMode = String.fromEnvironment(
    'CURRENCY_API_MODE',
    defaultValue: countryApiMode,
  );
  const currencyApiBaseUrl = String.fromEnvironment(
    'CURRENCY_API_BASE_URL',
    defaultValue: countryApiBaseUrl,
  );
  const issuerApiMode = String.fromEnvironment(
    'ISSUER_API_MODE',
    defaultValue: currencyApiMode,
  );
  const issuerApiBaseUrl = String.fromEnvironment(
    'ISSUER_API_BASE_URL',
    defaultValue: currencyApiBaseUrl,
  );

  configureBondApi(modeText: bondApiMode, baseUrl: bondApiBaseUrl);
  configureVendorApi(
    modeText: vendorApiMode,
    baseUrl: vendorApiBaseUrl,
    authToken: vendorApiAuthToken,
  );
  configureCalendarApi(modeText: calendarApiMode, baseUrl: calendarApiBaseUrl);
  configureCountryApi(modeText: countryApiMode, baseUrl: countryApiBaseUrl);
  configureCurrencyApi(modeText: currencyApiMode, baseUrl: currencyApiBaseUrl);
  configureIssuerApi(modeText: issuerApiMode, baseUrl: issuerApiBaseUrl);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financial Platform',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
