import '../models/list_item_model.dart';
import '../models/bond_form_data.dart';

/// Bond API interface shared by Mock and Remote implementations.
abstract class BondApi {
  /// Fetch list items.
  Future<List<ListItemModel>> getList();

  /// Fetch details by ID (data used to prefill the edit form).
  Future<BondFormData?> getById(String id);

  /// Create a new bond.
  Future<BondFormData> create(BondFormData data);

  /// Update an existing bond.
  Future<BondFormData> update(BondFormData data);

  /// Delete by ID.
  Future<void> delete(String id);
}
