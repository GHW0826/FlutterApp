import '../models/reference_master_form_data.dart';
import 'vendor_api.dart';

/// Mock implementation for vendor CRUD.
class MockVendorApi implements VendorApi {
  MockVendorApi() {
    _storage.addAll(_seedData);
  }

  final List<ReferenceMasterFormData> _storage = [];

  static List<ReferenceMasterFormData> get _seedData => const [
    ReferenceMasterFormData(
      id: 'ven_1',
      code: 'BBG',
      name: 'Bloomberg',
      vendorStatus: VendorStatus.active,
      description: 'Market data vendor',
    ),
    ReferenceMasterFormData(
      id: 'ven_2',
      code: 'RFT',
      name: 'Refinitiv',
      vendorStatus: VendorStatus.inactive,
      description: 'Legacy feed',
    ),
    ReferenceMasterFormData(
      id: 'ven_3',
      code: 'MDL',
      name: 'MarketData Lab',
      vendorStatus: VendorStatus.suspended,
    ),
    ReferenceMasterFormData(
      id: 'ven_4',
      code: 'LGY',
      name: 'Legacy Feed',
      vendorStatus: VendorStatus.deprecated,
    ),
  ];

  @override
  Future<List<ReferenceMasterFormData>> getList({
    bool? active,
    VendorStatus? status,
    int page = 0,
    int size = 20,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    var list = List<ReferenceMasterFormData>.from(_storage);
    if (active != null) {
      list = list.where((e) => (e.active ?? true) == active).toList();
    }
    if (status != null) {
      list = list.where((e) => e.vendorStatus == status).toList();
    }
    final start = page * size;
    if (start >= list.length) return [];
    final end = (start + size).clamp(0, list.length).toInt();
    return list.sublist(start, end);
  }

  @override
  Future<ReferenceMasterFormData?> findById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
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
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final normalized = _normalizeForSave(data);
    final id = normalized.id ?? 'ven_${DateTime.now().millisecondsSinceEpoch}';
    final created = normalized.copyWith(id: id);
    _storage.removeWhere((e) => e.code == created.code);
    _storage.insert(0, created);
    return created;
  }

  @override
  Future<ReferenceMasterFormData> patch(ReferenceMasterFormData data) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final id = (data.id ?? '').trim();
    if (id.isEmpty) {
      throw StateError('Vendor id is required.');
    }
    final idx = _storage.indexWhere((e) => e.id == id);
    if (idx < 0) {
      throw StateError('Vendor not found: $id');
    }
    _storage[idx] = _normalizeForSave(data).copyWith(id: id);
    return _storage[idx];
  }

  @override
  Future<ReferenceMasterFormData> put(ReferenceMasterFormData data) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final id = (data.id ?? '').trim();
    if (id.isEmpty) {
      throw StateError('Vendor id is required.');
    }
    final idx = _storage.indexWhere((e) => e.id == id);
    if (idx < 0) {
      throw StateError('Vendor not found: $id');
    }
    _storage[idx] = _normalizeForSave(data).copyWith(id: id);
    return _storage[idx];
  }

  @override
  Future<ReferenceMasterFormData> update(ReferenceMasterFormData data) {
    return patch(data);
  }

  @override
  Future<void> delete({required String id}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _storage.removeWhere((e) => e.id == id);
  }

  ReferenceMasterFormData _normalizeForSave(ReferenceMasterFormData data) {
    final id = (data.id ?? '').trim();
    final code = data.code.trim();
    final name = data.name.trim();
    if (code.isEmpty || name.isEmpty) {
      throw StateError('vendorCode/vendorName is required.');
    }
    final duplicate = _storage.any(
      (e) => e.id != id && e.code.trim().toUpperCase() == code.toUpperCase(),
    );
    if (duplicate) {
      throw StateError('Duplicate vendorCode: $code');
    }

    return data.copyWith(
      code: code,
      name: name,
      description: data.description.trim(),
    );
  }
}
