import '../models/reference_master_form_data.dart';

abstract class CurrencyApi {
  Future<List<ReferenceMasterFormData>> getList({bool? active});

  Future<ReferenceMasterFormData?> getById(String id);

  Future<ReferenceMasterFormData> create(ReferenceMasterFormData data);

  Future<ReferenceMasterFormData> patch(ReferenceMasterFormData data);

  Future<ReferenceMasterFormData> put(ReferenceMasterFormData data);

  Future<ReferenceMasterFormData> update(ReferenceMasterFormData data) =>
      patch(data);

  Future<void> delete(String id);
}
