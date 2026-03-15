import '../models/issuer_form_data.dart';

abstract class IssuerApi {
  Future<List<IssuerFormData>> getList({bool? active});

  Future<IssuerFormData?> getById(String id);

  Future<IssuerFormData?> findByIssuerCode(String issuerCode);

  Future<IssuerFormData> create(IssuerFormData data);

  Future<IssuerFormData> patch(IssuerFormData data);

  Future<IssuerFormData> put(IssuerFormData data);

  Future<IssuerFormData> update(IssuerFormData data) => patch(data);

  Future<void> delete({required String id});
}
