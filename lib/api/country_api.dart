import '../models/country_form_data.dart';

abstract class CountryApi {
  Future<List<CountryFormData>> getList({bool? active});

  Future<CountryFormData?> getById(String id);

  Future<CountryFormData> create(CountryFormData data);

  Future<CountryFormData> patch(CountryFormData data);

  Future<CountryFormData> put(CountryFormData data);

  Future<CountryFormData> update(CountryFormData data) => patch(data);

  Future<void> delete(String id);
}
