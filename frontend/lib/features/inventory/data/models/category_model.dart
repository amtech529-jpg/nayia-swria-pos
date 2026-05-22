class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final String? parentId;
  final String? parentName;
  final bool deleted;
  final bool synced;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.parentId,
    this.parentName,
    this.deleted = false,
    this.synced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'parent': parentId,
      'deleted': deleted,
      'synced': synced,
    };
  }

  factory CategoryModel.fromMap(Map<dynamic, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      parentId: map['parent']?.toString(),
      parentName: map['parent_name'] as String?,
      deleted: map['deleted'] == true || map['deleted'] == 1,
      synced: map['synced'] == true || map['synced'] == 1,
    );
  }
}
