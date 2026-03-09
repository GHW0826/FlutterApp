import '../models/issuer_form_data.dart';
import 'issuer_api.dart';

class MockIssuerApi implements IssuerApi {
  MockIssuerApi() {
    _storage.addAll(_seedData);
  }

  final List<IssuerFormData> _storage = [];

  static List<IssuerFormData> get _seedData => const [
    IssuerFormData(
      id: '1',
      issuerCode: 'GOVT',
      code: 'GOVT',
      name: 'Government',
      shortName: 'GOVT',
      activeFlag: true,
      description: 'Top issuer type for sovereign entities',
    ),
    IssuerFormData(
      id: '2',
      issuerCode: 'AGENCY',
      code: 'AGENCY',
      name: 'Agency',
      shortName: 'AGY',
      activeFlag: true,
      description: 'Top issuer type for agency entities',
    ),
    IssuerFormData(
      id: '3',
      issuerCode: 'CORP',
      code: 'CORP',
      name: 'Corporate',
      shortName: 'CORP',
      activeFlag: true,
      description: 'Top issuer type for corporate entities',
    ),
    IssuerFormData(
      id: '4',
      issuerCode: 'ROK',
      code: 'ROK',
      name: 'Republic of Korea',
      shortName: 'KOREA',
      countryIso2: 'KR',
      parentIssuerCode: 'GOVT',
      activeFlag: true,
      description: 'Sovereign issuer',
    ),
    IssuerFormData(
      id: '5',
      issuerCode: 'KDB',
      code: 'KDB',
      name: 'Korea Development Bank',
      shortName: 'KDB',
      countryIso2: 'KR',
      lei: '549300H6L6A8YTXP2R28',
      parentIssuerCode: 'AGENCY',
      activeFlag: true,
      description: 'Policy bank issuer',
    ),
    IssuerFormData(
      id: '6',
      issuerCode: 'SAMSUNG_ELEC',
      code: 'SAMSUNG_ELEC',
      name: 'Samsung Electronics',
      shortName: 'SEC',
      countryIso2: 'KR',
      parentIssuerCode: 'CORP',
      activeFlag: true,
      description: 'Corporate issuer example',
    ),
  ];

  @override
  Future<List<IssuerFormData>> getList({bool? active}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    var list = List<IssuerFormData>.from(_storage);
    if (active != null) {
      list = list.where((e) => e.activeFlag == active).toList();
    }
    return list;
  }

  @override
  Future<IssuerFormData?> getById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final key = id.trim();
    if (key.isEmpty) return null;
    try {
      return _storage.firstWhere((e) => (e.id ?? '').trim() == key);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<IssuerFormData?> findByIssuerCode(String issuerCode) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final key = issuerCode.trim();
    if (key.isEmpty) return null;
    try {
      return _storage.firstWhere((e) => e.issuerCode == key);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<IssuerFormData> create(IssuerFormData data) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final created = _normalizeForSave(
      data,
    ).copyWith(id: data.id ?? DateTime.now().millisecondsSinceEpoch.toString());
    _storage.insert(0, created);
    return created;
  }

  @override
  Future<IssuerFormData> patch(IssuerFormData data) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final id = (data.id ?? '').trim();
    if (id.isEmpty) {
      throw StateError('id is required.');
    }
    final idx = _storage.indexWhere((e) => e.id == id);
    if (idx < 0) {
      throw StateError('Issuer not found: $id');
    }
    final updated = _normalizeForSave(data).copyWith(id: id);
    _storage[idx] = updated;
    return updated;
  }

  @override
  Future<IssuerFormData> put(IssuerFormData data) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final id = (data.id ?? '').trim();
    if (id.isEmpty) {
      throw StateError('id is required.');
    }
    final idx = _storage.indexWhere((e) => e.id == id);
    if (idx < 0) {
      throw StateError('Issuer not found: $id');
    }
    final replaced = _normalizeForSave(data).copyWith(id: id);
    _storage[idx] = replaced;
    return replaced;
  }

  @override
  Future<IssuerFormData> update(IssuerFormData data) {
    return patch(data);
  }

  @override
  Future<void> delete({required String id}) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final key = id.trim();
    _storage.removeWhere((e) => e.id == key);
  }

  IssuerFormData _normalizeForSave(IssuerFormData data) {
    final issuerCode = data.issuerCode.trim();
    final code = data.code.trim();
    final name = data.name.trim();
    if (issuerCode.isEmpty || code.isEmpty || name.isEmpty) {
      throw StateError('issuerCode/code/name is required.');
    }
    final exists = _storage.any(
      (e) =>
          e.issuerCode != issuerCode &&
          (e.issuerCode == issuerCode || e.code == code),
    );
    if (exists) {
      throw StateError('Duplicate issuerCode or code.');
    }
    return data.copyWith(
      issuerCode: issuerCode,
      code: code,
      name: name,
      shortName: data.shortName.trim(),
      countryIso2: data.countryIso2.trim().toUpperCase(),
      lei: data.lei.trim(),
      parentIssuerCode: data.parentIssuerCode.trim(),
      description: data.description.trim(),
    );
  }
}
