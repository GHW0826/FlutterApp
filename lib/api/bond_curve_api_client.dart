import 'bond_curve_api.dart';
import 'mock_bond_curve_api.dart';

BondCurveApi get bondCurveApi => _bondCurveApi;
BondCurveApi _bondCurveApi = MockBondCurveApi();

void useMockBondCurveApi() {
  _bondCurveApi = MockBondCurveApi();
}
