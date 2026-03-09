import '../models/reference_master_form_data.dart';
import 'currency_api.dart';

class MockCurrencyApi implements CurrencyApi {
  MockCurrencyApi() {
    _storage.addAll(_seedData);
  }

  final List<ReferenceMasterFormData> _storage = [];

  static List<ReferenceMasterFormData> get _seedData => const [
    ReferenceMasterFormData(
      id: '1',
      code: 'KRW',
      name: 'Korean Won',
      active: true,
      description: 'South Korean won',
    ),
    ReferenceMasterFormData(
      id: '2',
      code: 'USD',
      name: 'US Dollar',
      active: true,
      description: 'United States dollar',
    ),
    ReferenceMasterFormData(
      id: '3',
      code: 'JPY',
      name: 'Japanese Yen',
      active: false,
      description: 'Inactive sample currency',
    ),
  ];

  @override
  Future<List<ReferenceMasterFormData>> getList({bool? active}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (active == null) {
      return List<ReferenceMasterFormData>.from(_storage);
    }
    return _storage.where((e) => (e.active ?? true) == active).toList();
  }

  @override
  Future<ReferenceMasterFormData?> getById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) return null;
    try {
      return _storage.firstWhere((e) => (e.id ?? '').trim() == normalizedId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ReferenceMasterFormData> create(ReferenceMasterFormData data) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final normalized = _normalize(data);
    final created = normalized.copyWith(
      id: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
    );
    _storage.removeWhere(
      (e) => e.code.trim().toUpperCase() == created.code.trim().toUpperCase(),
    );
    _storage.insert(0, created);
    return created;
  }

  @override
  Future<ReferenceMasterFormData> patch(ReferenceMasterFormData data) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _saveExisting(data);
  }

  @override
  Future<ReferenceMasterFormData> put(ReferenceMasterFormData data) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _saveExisting(data);
  }

  @override
  Future<ReferenceMasterFormData> update(ReferenceMasterFormData data) {
    return patch(data);
  }

  @override
  Future<void> delete(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _storage.removeWhere((e) => e.id == id);
  }

  ReferenceMasterFormData _saveExisting(ReferenceMasterFormData data) {
    final id = (data.id ?? '').trim();
    if (id.isEmpty) {
      throw StateError('Currency id is required.');
    }
    final index = _storage.indexWhere((e) => e.id == id);
    if (index < 0) {
      throw StateError('Currency not found: $id');
    }
    final saved = _normalize(data).copyWith(id: id);
    _storage[index] = saved;
    return saved;
  }

  ReferenceMasterFormData _normalize(ReferenceMasterFormData data) {
    final id = (data.id ?? '').trim();
    final code = data.code.trim().toUpperCase();
    final name = data.name.trim();
    if (code.isEmpty || name.isEmpty) {
      throw StateError('currencyCode/currencyName is required.');
    }
    final duplicate = _storage.any(
      (e) => e.id != id && e.code.trim().toUpperCase() == code,
    );
    if (duplicate) {
      throw StateError('Duplicate currencyCode: $code');
    }
    return data.copyWith(
      code: code,
      name: name,
      active: data.active ?? true,
      description: data.description.trim(),
    );
  }
}
