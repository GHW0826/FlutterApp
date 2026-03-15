import 'package:flutter/material.dart';

import '../../api/currency_api_client.dart';
import '../../api/issuer_api_client.dart';
import '../../api/vendor_api_client.dart';
import '../../models/bond_form_data.dart';
import '../../models/issuer_form_data.dart';
import '../../models/reference_master_form_data.dart';

class BondEditScreen extends StatefulWidget {
  const BondEditScreen({super.key, this.initialData});

  final BondFormData? initialData;

  @override
  State<BondEditScreen> createState() => _BondEditScreenState();
}

class _BondEditScreenState extends State<BondEditScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _marketCodeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _defaultTradingContextIdController =
      TextEditingController();
  final TextEditingController _defaultValuationContextIdController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _isinController = TextEditingController();
  final TextEditingController _couponRateController = TextEditingController();
  final TextEditingController _faceValueController = TextEditingController();
  final TextEditingController _redemptionController = TextEditingController();

  List<ReferenceMasterFormData> _vendorOptions = [];
  List<ReferenceMasterFormData> _currencyOptions = [];
  List<IssuerFormData> _issuerOptions = [];
  bool _loadingOptions = true;

  String _vendorId = '';
  String _currencyId = '';
  String _issuerId = '';
  String _couponType = '';
  String _couponFrequency = '';
  String _dayCountConvention = '';
  DateTime? _issueDate;
  DateTime? _maturityDate;

  static const List<String> _couponTypeOptions = ['Fixed', 'Floating', 'Zero'];

  static const List<String> _couponFrequencyOptions = [
    'Annual',
    'SemiAnnual',
    'Quarterly',
    'Monthly',
    'None',
  ];

  static const List<String> _dayCountConventionOptions = [
    'ACT360',
    'ACT365F',
    'Thirty360',
  ];

  bool get _isCreate => widget.initialData == null;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _marketCodeController.text = data?.marketCode ?? '';
    _nameController.text = data?.name ?? '';
    _defaultTradingContextIdController.text =
        data?.defaultTradingContextId ?? '';
    _defaultValuationContextIdController.text =
        data?.defaultValuationContextId ?? '';
    _descriptionController.text = data?.description ?? '';
    _isinController.text = data?.isin ?? '';
    _couponRateController.text = _formatNumber(data?.couponRate);
    _faceValueController.text = _formatNumber(data?.faceValue);
    _redemptionController.text = _formatNumber(data?.redemption);
    _vendorId = data?.vendorId ?? '';
    _currencyId = data?.currencyId ?? '';
    _issuerId = data?.issuerId ?? '';
    _couponType = data?.couponType ?? '';
    _couponFrequency = data?.couponFrequency ?? '';
    _dayCountConvention = data?.dayCountConvention ?? '';
    _issueDate = data?.issueDate;
    _maturityDate = data?.maturityDate;
    _loadOptions();
  }

  @override
  void dispose() {
    _marketCodeController.dispose();
    _nameController.dispose();
    _defaultTradingContextIdController.dispose();
    _defaultValuationContextIdController.dispose();
    _descriptionController.dispose();
    _isinController.dispose();
    _couponRateController.dispose();
    _faceValueController.dispose();
    _redemptionController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    try {
      final results = await Future.wait([
        vendorApi.getList(size: 500),
        currencyApi.getList(),
        issuerApi.getList(),
      ]);
      if (!mounted) return;
      setState(() {
        _vendorOptions = results[0] as List<ReferenceMasterFormData>;
        _currencyOptions = results[1] as List<ReferenceMasterFormData>;
        _issuerOptions = results[2] as List<IssuerFormData>;
        _vendorId = _resolveReferenceId(_vendorId, _vendorOptions);
        _currencyId = _resolveReferenceId(_currencyId, _currencyOptions);
        _issuerId = _resolveIssuerId(_issuerId);
        _loadingOptions = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _vendorOptions = [];
        _currencyOptions = [];
        _issuerOptions = [];
        _loadingOptions = false;
      });
    }
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_issueDate != null &&
        _maturityDate != null &&
        _maturityDate!.isBefore(_issueDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('MaturityDate must be on or after IssueDate.'),
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      BondFormData(
        id: widget.initialData?.id,
        marketCode: _marketCodeController.text.trim(),
        vendorId: _vendorId,
        vendorName: _vendorNameForId(_vendorId),
        name: _nameController.text.trim(),
        currencyId: _currencyId,
        currencyCode: _currencyCodeForId(_currencyId),
        defaultTradingContextId: _defaultTradingContextIdController.text.trim(),
        defaultValuationContextId: _defaultValuationContextIdController.text
            .trim(),
        description: _descriptionController.text.trim(),
        isin: _isinController.text.trim(),
        issuerId: _issuerId,
        issuerName: _issuerNameForId(_issuerId),
        issueDate: _issueDate,
        maturityDate: _maturityDate,
        couponType: _couponType,
        couponRate: _parseDouble(_couponRateController.text),
        couponFrequency: _couponFrequency,
        dayCountConvention: _dayCountConvention,
        faceValue: _parseDouble(_faceValueController.text),
        redemption: _parseDouble(_redemptionController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isCreate ? 'MarketBond New' : 'MarketBond Edit'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: _loadingOptions ? null : _onSave,
            icon: const Icon(Icons.check, size: 20),
            label: const Text('Save'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loadingOptions
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildTextField(
                    label: 'MarketCode',
                    controller: _marketCodeController,
                    required: true,
                    readOnly: !_isCreate,
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    label: 'Vendor',
                    value: _vendorId,
                    required: true,
                    items: _vendorOptions
                        .where((item) => (item.id ?? '').isNotEmpty)
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item.id!,
                            child: Text(
                              '${item.code} | ${item.name.isEmpty ? item.code : item.name}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _vendorId = value ?? ''),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'Name',
                    controller: _nameController,
                    required: true,
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    label: 'Currency',
                    value: _currencyId,
                    required: true,
                    items: _currencyOptions
                        .where((item) => (item.id ?? '').isNotEmpty)
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item.id!,
                            child: Text('${item.code} | ${item.name}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _currencyId = value ?? ''),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'DefaultTradingContextId',
                    controller: _defaultTradingContextIdController,
                    keyboardType: TextInputType.number,
                    validator: _optionalIntegerValidator,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'DefaultValuationContextId',
                    controller: _defaultValuationContextIdController,
                    keyboardType: TextInputType.number,
                    validator: _optionalIntegerValidator,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'Description',
                    controller: _descriptionController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'Isin',
                    controller: _isinController,
                    required: true,
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    label: 'Issuer',
                    value: _issuerId,
                    items: _issuerOptions
                        .where((item) => (item.id ?? '').isNotEmpty)
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item.id!,
                            child: Text('${item.issuerCode} | ${item.name}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _issuerId = value ?? ''),
                  ),
                  const SizedBox(height: 12),
                  _buildDateField(
                    label: 'IssueDate',
                    value: _issueDate,
                    onPick: (value) => setState(() => _issueDate = value),
                  ),
                  const SizedBox(height: 12),
                  _buildDateField(
                    label: 'MaturityDate',
                    value: _maturityDate,
                    onPick: (value) => setState(() => _maturityDate = value),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    label: 'CouponType',
                    value: _couponType,
                    items: _couponTypeOptions
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _couponType = value ?? ''),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'CouponRate',
                    controller: _couponRateController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _optionalDecimalValidator,
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    label: 'CouponFrequency',
                    value: _couponFrequency,
                    items: _couponFrequencyOptions
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _couponFrequency = value ?? ''),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    label: 'DayCountConvention',
                    value: _dayCountConvention,
                    items: _dayCountConventionOptions
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _dayCountConvention = value ?? ''),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'FaceValue',
                    controller: _faceValueController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _optionalDecimalValidator,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'Redemption',
                    controller: _redemptionController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _optionalDecimalValidator,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool required = false,
    bool readOnly = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: const OutlineInputBorder(),
      ),
      validator:
          validator ??
          (required
              ? (value) =>
                    (value ?? '').trim().isEmpty ? '$label is required.' : null
              : null),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    bool required = false,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value.isEmpty ? null : value,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: const OutlineInputBorder(),
      ),
      items: items,
      onChanged: onChanged,
      validator: required
          ? (_) => value.trim().isEmpty ? '$label is required.' : null
          : null,
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onPick,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onPick(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value == null ? 'Select date' : _formatDate(value),
                style: value == null
                    ? TextStyle(color: Theme.of(context).hintColor)
                    : null,
              ),
            ),
            IconButton(
              onPressed: value == null ? null : () => onPick(null),
              icon: const Icon(Icons.close, size: 16),
              tooltip: 'Clear',
            ),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }

  String _resolveReferenceId(
    String rawId,
    List<ReferenceMasterFormData> options,
  ) {
    final normalized = rawId.trim();
    if (normalized.isEmpty) return '';
    for (final item in options) {
      if ((item.id ?? '') == normalized) {
        return normalized;
      }
    }
    return '';
  }

  String _resolveIssuerId(String rawId) {
    final normalized = rawId.trim();
    if (normalized.isEmpty) return '';
    for (final item in _issuerOptions) {
      if ((item.id ?? '') == normalized) {
        return normalized;
      }
    }
    return '';
  }

  String _vendorNameForId(String id) {
    for (final item in _vendorOptions) {
      if ((item.id ?? '') == id) {
        return item.name;
      }
    }
    return '';
  }

  String _currencyCodeForId(String id) {
    for (final item in _currencyOptions) {
      if ((item.id ?? '') == id) {
        return item.code;
      }
    }
    return '';
  }

  String _issuerNameForId(String id) {
    for (final item in _issuerOptions) {
      if ((item.id ?? '') == id) {
        return item.name;
      }
    }
    return '';
  }

  static String _formatNumber(double? value) {
    if (value == null) return '';
    if (value % 1 == 0) return value.toInt().toString();
    return value.toString();
  }

  static double? _parseDouble(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  static String? _optionalDecimalValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    return double.tryParse(text) == null ? 'Enter a valid number.' : null;
  }

  static String? _optionalIntegerValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    return int.tryParse(text) == null ? 'Enter a whole number.' : null;
  }

  static String _formatDate(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
