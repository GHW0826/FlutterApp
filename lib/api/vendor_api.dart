import '../models/reference_master_form_data.dart';

/// Vendor API interface shared by mock and remote implementations.
abstract class VendorApi {
  Future<List<ReferenceMasterFormData>> getList({
    bool? active,
    VendorStatus? status,
    int page = 0,
    int size = 20,
  });

  Future<ReferenceMasterFormData?> findById(String id);

  Future<ReferenceMasterFormData> create(ReferenceMasterFormData data);

  Future<ReferenceMasterFormData> patch(ReferenceMasterFormData data);

  Future<ReferenceMasterFormData> put(ReferenceMasterFormData data);

  Future<ReferenceMasterFormData> update(ReferenceMasterFormData data) =>
      patch(data);

  Future<void> delete({required String id});
}
