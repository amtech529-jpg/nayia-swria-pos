class UnitModel {
  final String id;
  final String name;
  final String shortName;
  final String? baseUnit;
  final double baseUnitMultiplier;

  UnitModel({
    required this.id,
    required this.name,
    required this.shortName,
    this.baseUnit,
    this.baseUnitMultiplier = 1.0,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['short_name'] ?? json['shortName'] as String,
      baseUnit: json['base_unit'] ?? json['baseUnit'],
      baseUnitMultiplier: double.tryParse((json['base_unit_multiplier'] ?? json['baseUnitMultiplier'] ?? '1.0').toString()) ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'short_name': shortName,
      'base_unit': baseUnit,
      'base_unit_multiplier': baseUnitMultiplier,
    };
  }

  UnitModel copyWith({
    String? id,
    String? name,
    String? shortName,
    String? baseUnit,
    double? baseUnitMultiplier,
  }) {
    return UnitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      baseUnit: baseUnit ?? this.baseUnit,
      baseUnitMultiplier: baseUnitMultiplier ?? this.baseUnitMultiplier,
    );
  }
}
