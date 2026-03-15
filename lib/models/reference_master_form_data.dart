import 'list_item_model.dart';

/// Form payload used by reference master registration screens.
class ReferenceMasterFormData {
  static const Object _unset = Object();

  const ReferenceMasterFormData({
    this.id,
    this.code = '',
    this.name = '',
    this.shortName = '',
    this.homepageUrl = '',
    this.vendorStatus,
    this.active,
    this.effectiveFrom,
    this.effectiveTo,
    this.description = '',
  });

  final String? id;
  final String code;
  final String name;
  final String shortName;
  final String homepageUrl;
  final VendorStatus? vendorStatus;
  final bool? active;
  final DateTime? effectiveFrom;
  final DateTime? effectiveTo;
  final String description;

  ReferenceMasterFormData copyWith({
    String? id,
    String? code,
    String? name,
    String? shortName,
    String? homepageUrl,
    VendorStatus? vendorStatus,
    Object? active = _unset,
    DateTime? effectiveFrom,
    DateTime? effectiveTo,
    String? description,
  }) {
    return ReferenceMasterFormData(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      homepageUrl: homepageUrl ?? this.homepageUrl,
      vendorStatus: vendorStatus ?? this.vendorStatus,
      active: active == _unset ? this.active : active as bool?,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      effectiveTo: effectiveTo ?? this.effectiveTo,
      description: description ?? this.description,
    );
  }

  ListItemModel toListItem({
    bool isVendor = false,
    bool includeActiveState = false,
  }) {
    final statusLabel = isVendor && vendorStatus != null
        ? vendorStatus!.uiLabel
        : includeActiveState && active != null
        ? (active! ? 'Active' : 'Inactive')
        : '';
    final subtitle = statusLabel.isEmpty ? code : '$code | $statusLabel';
    return ListItemModel(id: id ?? code, title: name, subtitle: subtitle);
  }

  static ReferenceMasterFormData fromListItem(
    ListItemModel item, {
    bool isVendor = false,
    bool isCurrency = false,
  }) {
    final subtitle = item.subtitle ?? '';
    final parts = subtitle.split('|').map((e) => e.trim()).toList();
    final code = parts.isNotEmpty && parts.first.isNotEmpty
        ? parts.first
        : subtitle.trim();
    final statusText = parts.length > 1 ? parts[1] : '';
    return ReferenceMasterFormData(
      id: item.id,
      code: code,
      name: item.title,
      shortName: '',
      homepageUrl: '',
      vendorStatus: isVendor ? VendorStatus.fromLabel(statusText) : null,
      active: isCurrency
          ? switch (statusText.toLowerCase()) {
              'active' => true,
              'inactive' => false,
              _ => null,
            }
          : null,
    );
  }
}

enum VendorStatus {
  active('ACTIVE', 'Active'),
  inactive('INACTIVE', 'Inactive'),
  suspended('SUSPENDED', 'Suspended'),
  deprecated('DEPRECATED', 'Deprecated');

  const VendorStatus(this.value, this.uiLabel);
  final String value;
  final String uiLabel;

  static VendorStatus? fromLabel(String? label) {
    if (label == null || label.trim().isEmpty) return null;
    final normalized = label.trim().toLowerCase();
    for (final status in VendorStatus.values) {
      if (status.uiLabel.toLowerCase() == normalized ||
          status.value.toLowerCase() == normalized) {
        return status;
      }
    }
    if (normalized.contains('active') && !normalized.contains('inactive')) {
      return VendorStatus.active;
    }
    if (normalized.contains('inactive')) return VendorStatus.inactive;
    if (normalized.contains('suspended')) return VendorStatus.suspended;
    if (normalized.contains('deprecated')) return VendorStatus.deprecated;
    return null;
  }
}
