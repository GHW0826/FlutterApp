class WeekendProfileFormData {
  const WeekendProfileFormData({
    this.id,
    this.weekendProfileCode = '',
    this.name = '',
    this.description = '',
  });

  final String? id;
  final String weekendProfileCode;
  final String name;
  final String description;

  WeekendProfileFormData copyWith({
    String? id,
    String? weekendProfileCode,
    String? name,
    String? description,
  }) {
    return WeekendProfileFormData(
      id: id ?? this.id,
      weekendProfileCode: weekendProfileCode ?? this.weekendProfileCode,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}
