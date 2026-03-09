/// 리스트 화면에서 API로 받아 표시·선택하는 공통 아이템 모델
class ListItemModel {
  const ListItemModel({
    required this.id,
    required this.title,
    this.subtitle,
  });

  final String id;
  final String title;
  final String? subtitle;
}
