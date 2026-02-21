import 'package:flutter/material.dart';
import '../../models/bond_enums.dart';
import '../../models/list_item_model.dart';
import '../../models/underlying_bond_form_data.dart';

class UnderlyingBondEditScreen extends StatefulWidget {
  const UnderlyingBondEditScreen({
    super.key,
    this.initialData,
    required this.marketDataOptions,
    required this.resolveMarketCcy,
  });

  final UnderlyingBondFormData? initialData;
  final List<ListItemModel> marketDataOptions;
  final Future<Ccy?> Function(String marketDataCode) resolveMarketCcy;

  @override
  State<UnderlyingBondEditScreen> createState() => _UnderlyingBondEditScreenState();
}

class _UnderlyingBondEditScreenState extends State<UnderlyingBondEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  String? _marketDataCode;
  String _marketDataName = '';
  Ccy? _ccy;
  bool _resolvingCcy = false;

  HolidayCity? _holidayCity;
  HolidayAdjustmentRule? _holidayRule;
  CouponFrequency? _couponFrequency;
  PaymentFrequency? _paymentFrequency;
  List<CouponPeriodRow> _couponPeriods = const [];

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _nameController = TextEditingController(text: d?.name ?? '');
    _marketDataCode = d?.marketDataCode.isNotEmpty == true ? d!.marketDataCode : null;
    _marketDataName = d?.marketDataName ?? '';
    _ccy = d?.ccy;
    _holidayCity = d?.holidayCity;
    _holidayRule = d?.holidayRule;
    _couponFrequency = d?.couponFrequency;
    _paymentFrequency = d?.paymentFrequency;
    _couponPeriods = d?.couponPeriods ?? const [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _onMarketDataChanged(String? value) async {
    setState(() {
      _marketDataCode = value;
      _marketDataName = _marketDataLabel(value);
      _ccy = null;
    });
    if (value == null || value.isEmpty) return;

    setState(() => _resolvingCcy = true);
    try {
      final ccy = await widget.resolveMarketCcy(value);
      if (!mounted) return;
      setState(() => _ccy = ccy);
    } catch (_) {
      if (!mounted) return;
      setState(() => _ccy = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('통신오류')),
      );
    } finally {
      if (mounted) setState(() => _resolvingCcy = false);
    }
  }

  String _marketDataLabel(String? code) {
    if (code == null || code.isEmpty) return '';
    final item = widget.marketDataOptions.where((e) {
      final itemCode = (e.subtitle?.trim().isNotEmpty ?? false) ? e.subtitle!.trim() : e.id;
      return itemCode == code;
    }).firstOrNull;
    return item?.title ?? '';
  }

  List<DropdownMenuItem<String?>> _marketDataItems(BuildContext context) {
    return [
      DropdownMenuItem<String?>(
        value: null,
        child: Text('선택', style: TextStyle(color: Theme.of(context).hintColor)),
      ),
      ...widget.marketDataOptions.map((e) {
        final code = (e.subtitle?.trim().isNotEmpty ?? false) ? e.subtitle!.trim() : e.id;
        final name = e.title;
        return DropdownMenuItem<String?>(
          value: code,
          child: Text('$name ($code)'),
        );
      }),
    ];
  }

  void _generateDummyCouponPeriods() {
    final now = DateTime.now();
    final rows = List<CouponPeriodRow>.generate(6, (index) {
      final start = DateTime(now.year, now.month + (index * 6), now.day);
      final end = DateTime(now.year, now.month + ((index + 1) * 6), now.day);
      final pay = end.add(const Duration(days: 2));
      return CouponPeriodRow(
        no: index + 1,
        startDate: start,
        endDate: end,
        paymentDate: pay,
      );
    });
    setState(() => _couponPeriods = rows);
  }

  String _fmtDate(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final result = UnderlyingBondFormData(
      id: widget.initialData?.id,
      name: _nameController.text.trim(),
      marketDataCode: _marketDataCode ?? '',
      marketDataName: _marketDataName,
      ccy: _ccy,
      holidayCity: _holidayCity,
      holidayRule: _holidayRule,
      couponFrequency: _couponFrequency,
      paymentFrequency: _paymentFrequency,
      couponPeriods: _couponPeriods,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.initialData == null ? 'Underlying Bond 신규' : 'Underlying Bond 수정'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            TextButton.icon(
              onPressed: _onSave,
              icon: const Icon(Icons.check, size: 20),
              label: const Text('Save'),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Basic'),
              Tab(text: 'Coupon Period'),
            ],
          ),
        ),
        body: Form(
          key: _formKey,
          child: TabBarView(
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Name 필수' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: _marketDataCode,
                    decoration: const InputDecoration(
                      labelText: 'Market Data',
                      border: OutlineInputBorder(),
                    ),
                    items: _marketDataItems(context),
                    onChanged: _onMarketDataChanged,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Market Data 필수' : null,
                  ),
                  const SizedBox(height: 12),
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Ccy',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(_resolvingCcy ? '조회중...' : (_ccy?.label ?? '')),
                  ),
                ],
              ),
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  DropdownButtonFormField<HolidayCity?>(
                    initialValue: _holidayCity,
                    decoration: const InputDecoration(
                      labelText: 'Holiday City',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem<HolidayCity?>(
                        value: null,
                        child: Text('선택', style: TextStyle(color: Theme.of(context).hintColor)),
                      ),
                      ...HolidayCity.values.map(
                        (e) => DropdownMenuItem<HolidayCity?>(
                          value: e,
                          child: Text(e.label),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _holidayCity = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<HolidayAdjustmentRule?>(
                    initialValue: _holidayRule,
                    decoration: const InputDecoration(
                      labelText: 'Holiday Rule',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem<HolidayAdjustmentRule?>(
                        value: null,
                        child: Text('선택', style: TextStyle(color: Theme.of(context).hintColor)),
                      ),
                      ...HolidayAdjustmentRule.values.map(
                        (e) => DropdownMenuItem<HolidayAdjustmentRule?>(
                          value: e,
                          child: Text(e.label),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _holidayRule = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<CouponFrequency?>(
                    initialValue: _couponFrequency,
                    decoration: const InputDecoration(
                      labelText: 'Coupon Frequency',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem<CouponFrequency?>(
                        value: null,
                        child: Text('선택', style: TextStyle(color: Theme.of(context).hintColor)),
                      ),
                      ...CouponFrequency.values.map(
                        (e) => DropdownMenuItem<CouponFrequency?>(
                          value: e,
                          child: Text(e.label),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _couponFrequency = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<PaymentFrequency?>(
                    initialValue: _paymentFrequency,
                    decoration: const InputDecoration(
                      labelText: 'Payment Frequency',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem<PaymentFrequency?>(
                        value: null,
                        child: Text('선택', style: TextStyle(color: Theme.of(context).hintColor)),
                      ),
                      ...PaymentFrequency.values.map(
                        (e) => DropdownMenuItem<PaymentFrequency?>(
                          value: e,
                          child: Text(e.label),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _paymentFrequency = v),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.icon(
                      onPressed: _generateDummyCouponPeriods,
                      icon: const Icon(Icons.auto_fix_high),
                      label: const Text('쿠폰기간 더미 생성'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_couponPeriods.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('쿠폰기간 데이터가 없습니다.'),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('No')),
                          DataColumn(label: Text('Start Date')),
                          DataColumn(label: Text('End Date')),
                          DataColumn(label: Text('Payment Date')),
                        ],
                        rows: _couponPeriods
                            .map(
                              (e) => DataRow(
                                cells: [
                                  DataCell(Text('${e.no}')),
                                  DataCell(Text(_fmtDate(e.startDate))),
                                  DataCell(Text(_fmtDate(e.endDate))),
                                  DataCell(Text(_fmtDate(e.paymentDate))),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
