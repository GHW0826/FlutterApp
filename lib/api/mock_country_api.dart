import '../models/country_form_data.dart';
import 'country_api.dart';

class MockCountryApi implements CountryApi {
  MockCountryApi() {
    _items.addAll(_seedItems);
  }

  final List<CountryFormData> _items = [];

  static List<CountryFormData> get _seedItems => const [
    CountryFormData(
      id: '1',
      countryIso2: 'KR',
      countryIso3: 'KOR',
      numericCode: '410',
      name: 'Korea',
      timezone: 'Asia/Seoul',
      active: true,
      description: 'Seed data',
    ),
    CountryFormData(
      id: '2',
      countryIso2: 'US',
      countryIso3: 'USA',
      numericCode: '840',
      name: 'United States',
      timezone: 'America/New_York',
      active: true,
      description: 'Seed data',
    ),
    CountryFormData(
      id: '3',
      countryIso2: 'JP',
      countryIso3: 'JPN',
      numericCode: '392',
      name: 'Japan',
      timezone: 'Asia/Tokyo',
      active: true,
      description: 'Seed data',
    ),
  ];

  @override
  Future<List<CountryFormData>> getList({bool? active}) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final filtered = active == null
        ? _items
        : _items.where((item) => item.active == active).toList();
    return List<CountryFormData>.from(filtered);
  }

  @override
  Future<CountryFormData?> getById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) return null;
    try {
      return _items.firstWhere((item) => item.id == normalizedId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<CountryFormData> create(CountryFormData data) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final normalized = _normalizeForSave(data);
    final created = normalized.copyWith(
      id: data.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
    );
    _items.insert(0, created);
    return created;
  }

  @override
  Future<CountryFormData> patch(CountryFormData data) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final id = (data.id ?? '').trim();
    if (id.isEmpty) {
      throw StateError('Country id is required.');
    }
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) {
      throw StateError('Country not found: $id');
    }

    final updated = _normalizeForSave(data).copyWith(id: id);
    _items[index] = updated;
    return updated;
  }

  @override
  Future<CountryFormData> put(CountryFormData data) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final id = (data.id ?? '').trim();
    if (id.isEmpty) {
      throw StateError('Country id is required.');
    }
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) {
      throw StateError('Country not found: $id');
    }

    final replaced = _normalizeForSave(data).copyWith(id: id);
    _items[index] = replaced;
    return replaced;
  }

  @override
  Future<CountryFormData> update(CountryFormData data) {
    return patch(data);
  }

  @override
  Future<void> delete(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _items.removeWhere((item) => item.id == id);
  }

  CountryFormData _normalizeForSave(CountryFormData data) {
    final iso2 = data.countryIso2.trim().toUpperCase();
    final iso3 = data.countryIso3.trim().toUpperCase();
    final name = data.name.trim();
    if (iso2.isEmpty || name.isEmpty) {
      throw StateError('countryIso2/name is required.');
    }
    if (_items.any((item) => item.id != data.id && item.countryIso2 == iso2)) {
      throw StateError('Duplicate countryIso2: $iso2');
    }
    if (iso3.isNotEmpty &&
        _items.any((item) => item.id != data.id && item.countryIso3 == iso3)) {
      throw StateError('Duplicate countryIso3: $iso3');
    }

    return data.copyWith(
      countryIso2: iso2,
      countryIso3: iso3,
      numericCode: data.numericCode.trim(),
      name: name,
      timezone: data.timezone.trim(),
      description: data.description.trim(),
    );
  }
}
