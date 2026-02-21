import 'package:flutter/material.dart';
import '../../models/bond_form_data.dart';
import '../../models/bond_enums.dart';

/// Bond 신규/수정 입력 화면
class BondEditScreen extends StatefulWidget {
  const BondEditScreen({super.key, this.initialData});

  /// Edit 시 선택한 항목 정보 (null이면 신규)
  final BondFormData? initialData;

  @override
  State<BondEditScreen> createState() => _BondEditScreenState();
}

class _BondEditScreenState extends State<BondEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _marketCodeController;
  late TextEditingController _nameController;
  late TextEditingController _sourceController;
  late TextEditingController _originCodeController;
  late TextEditingController _entityOriginSourceController;
  late TextEditingController _descriptionController;

  Ccy? _ccy;
  IntPayMethod? _intPayMethod;
  LiquiditySect? _liquiditySect;
  SubordSect? _subordSect;
  DateTime? _issueDate;
  DateTime? _maturityDate;
  OriginSource? _originSource;
  SourceCode? _sourceCode;
  EntityOriginCode? _entityOriginCode;
  IssueKind? _issueKind;
  IssuePurpose? _issuePurpose;
  ListingSection? _listingSection;
  AssetSecuritizationClassification? _assetSecuritizationClassification;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _marketCodeController = TextEditingController(text: d?.marketCode ?? '');
    _nameController = TextEditingController(text: d?.name ?? '');
    _sourceController = TextEditingController(text: d?.source ?? '');
    _originCodeController = TextEditingController(text: d?.originCode ?? '');
    _entityOriginSourceController = TextEditingController(text: d?.entityOriginSource ?? '');
    _descriptionController = TextEditingController(text: d?.description ?? '');
    _ccy = d?.ccy;
    _intPayMethod = d?.intPayMethod;
    _liquiditySect = d?.liquiditySect;
    _subordSect = d?.subordSect;
    _issueDate = d?.issueDate;
    _maturityDate = d?.maturityDate;
    _originSource = d?.originSource;
    _sourceCode = d?.sourceCode;
    _entityOriginCode = d?.entityOriginCode;
    _issueKind = d?.issueKind;
    _issuePurpose = d?.issuePurpose;
    _listingSection = d?.listingSection;
    _assetSecuritizationClassification = d?.assetSecuritizationClassification;
  }

  @override
  void dispose() {
    _marketCodeController.dispose();
    _nameController.dispose();
    _sourceController.dispose();
    _originCodeController.dispose();
    _entityOriginSourceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  BondFormData _buildFormData() {
    return BondFormData(
      id: widget.initialData?.id,
      marketCode: _marketCodeController.text.trim(),
      name: _nameController.text.trim(),
      ccy: _ccy,
      intPayMethod: _intPayMethod,
      liquiditySect: _liquiditySect,
      subordSect: _subordSect,
      issueDate: _issueDate,
      maturityDate: _maturityDate,
      source: _sourceController.text.trim(),
      sourceCode: _sourceCode,
      originSource: _originSource,
      originCode: _originCodeController.text.trim(),
      entityOriginSource: _entityOriginSourceController.text.trim(),
      entityOriginCode: _entityOriginCode,
      issueKind: _issueKind,
      issuePurpose: _issuePurpose,
      listingSection: _listingSection,
      assetSecuritizationClassification: _assetSecuritizationClassification,
      description: _descriptionController.text.trim(),
    );
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(_buildFormData());
    }
  }

  Future<void> _pickDate(BuildContext context, bool isIssueDate) async {
    final initial = isIssueDate ? _issueDate : _maturityDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isIssueDate) {
          _issueDate = picked;
        } else {
          _maturityDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialData == null ? 'Bond 신규' : 'Bond 수정'),
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
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField('Market Code', _marketCodeController, required: true),
            _buildTextField('Name', _nameController, required: true),
            _buildDropdown<Ccy>('Ccy', Ccy.values, _ccy, (v) => setState(() => _ccy = v), (e) => e.label),
            _buildDropdown<IntPayMethod>('Int.PayMethod', IntPayMethod.values, _intPayMethod, (v) => setState(() => _intPayMethod = v), (e) => e.label),
            _buildDropdown<LiquiditySect>('Liquidity Sect', LiquiditySect.values, _liquiditySect, (v) => setState(() => _liquiditySect = v), (e) => e.label),
            _buildDropdown<SubordSect>('Subord Sect', SubordSect.values, _subordSect, (v) => setState(() => _subordSect = v), (e) => e.label),
            _buildDateField('Issue Date', _issueDate, () => _pickDate(context, true)),
            _buildDateField('Maturity Date', _maturityDate, () => _pickDate(context, false)),
            _buildTextField('Source', _sourceController),
            _buildDropdown<SourceCode>('Source Code', SourceCode.values, _sourceCode, (v) => setState(() => _sourceCode = v), (e) => e.label),
            _buildDropdown<ListingSection>('Listing Section', ListingSection.values, _listingSection, (v) => setState(() => _listingSection = v), (e) => e.label),
            _buildDropdown<AssetSecuritizationClassification>(
              'Asset Securitization',
              AssetSecuritizationClassification.values,
              _assetSecuritizationClassification,
              (v) => setState(() => _assetSecuritizationClassification = v),
              (e) => e.label,
            ),
            _buildDropdown<OriginSource>('Origin Source', OriginSource.values, _originSource, (v) => setState(() => _originSource = v), (e) => e.label),
            _buildTextField('Origin Code', _originCodeController),
            _buildTextField('Entity Origin Source', _entityOriginSourceController),
            _buildDropdown<EntityOriginCode>('Entity Origin Code', EntityOriginCode.values, _entityOriginCode, (v) => setState(() => _entityOriginCode = v), (e) => e.label),
            _buildDropdown<IssueKind>('IssueKind', IssueKind.values, _issueKind, (v) => setState(() => _issueKind = v), (e) => e.label),
            _buildDropdown<IssuePurpose>('IssuePurpose', IssuePurpose.values, _issuePurpose, (v) => setState(() => _issuePurpose = v), (e) => e.label),
            _buildTextField('Description', _descriptionController, maxLines: 3),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool required = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? '$label 필수' : null : null,
      ),
    );
  }

  Widget _buildDropdown<T>(String label, List<T> values, T? value, ValueChanged<T?> onChanged, String Function(T) labelOf) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<T?>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: [
          DropdownMenuItem<T?>(value: null, child: Text('선택', style: TextStyle(color: Theme.of(context).hintColor))),
          ...values.map((e) => DropdownMenuItem<T?>(value: e, child: Text(labelOf(e)))),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? value, VoidCallback onTap) {
    final text = value == null ? '' : '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 140, child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                child: Text(text.isEmpty ? '날짜 선택' : text, style: TextStyle(color: text.isEmpty ? Theme.of(context).hintColor : null)),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: onTap,
            tooltip: '날짜 선택',
          ),
        ],
      ),
    );
  }
}
