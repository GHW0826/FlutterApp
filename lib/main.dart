import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'api/calendar_api_client.dart';
import 'api/bond_api_client.dart';
import 'api/country_api_client.dart';
import 'api/currency_api_client.dart';
import 'api/issuer_api_client.dart';
import 'api/vendor_api_client.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import 'widgets/settings_dock.dart';

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppSettingsController _settings = AppSettingsController(
    initialThemeMode: ThemeMode.dark,
    initialLocale: const Locale('en'),
  );

  @override
  void dispose() {
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppThemeScope(
      controller: _settings,
      child: ListenableBuilder(
        listenable: _settings,
        builder: (context, _) {
          return MaterialApp(
            title: 'Financial Platform',
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(Brightness.light),
            darkTheme: buildAppTheme(Brightness.dark),
            themeMode: _settings.themeMode,
            themeAnimationDuration: Duration.zero,
            locale: _settings.locale,
            supportedLocales: const [Locale('en'), Locale('ko')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            builder: (context, child) {
              return Stack(
                children: [if (child != null) child, const SettingsDock()],
              );
            },
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
