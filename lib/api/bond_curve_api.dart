import '../models/bond_curve_build_method_form_data.dart';
import '../models/bond_curve_master_form_data.dart';
import '../models/list_item_model.dart';

abstract class BondCurveApi {
  Future<List<ListItemModel>> getMasterList();
  Future<BondCurveMasterFormData?> getMasterById(String id);
  Future<BondCurveMasterFormData> createMaster(BondCurveMasterFormData data);
  Future<BondCurveMasterFormData> updateMaster(BondCurveMasterFormData data);
  Future<void> deleteMaster(String id);

  Future<List<ListItemModel>> getBuildMethodList();
  Future<BondCurveBuildMethodFormData?> getBuildMethodById(String id);
  Future<BondCurveBuildMethodFormData> createBuildMethod(
    BondCurveBuildMethodFormData data,
  );
  Future<BondCurveBuildMethodFormData> updateBuildMethod(
    BondCurveBuildMethodFormData data,
  );
  Future<void> deleteBuildMethod(String id);
}
