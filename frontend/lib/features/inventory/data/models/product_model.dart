class ProductModel {
  final String id;
  final String name;
  final String? sku;
  final double margin;
  final String? categoryId;
  final String? categoryName;
  final double openingStock;
  final double cost;
  final double price;
  final double alertQty;
  final String location;
  final String saleUnit;
  final String extraUnits;
  final String baseUnit;
  final String purchaseUnit;
  final String? brand;
  final int daysInExpiry;
  final String status;
  final String? notes;
  final bool deleted;
  final bool synced;

  ProductModel({
    required this.id,
    required this.name,
    this.sku,
    this.margin = 0.0,
    this.categoryId,
    this.categoryName,
    this.openingStock = 0.0,
    required this.cost,
    required this.price,
    this.alertQty = 1.0,
    this.location = 'Default',
    this.saleUnit = 'Sale Unit',
    this.extraUnits = 'Extra Units',
    this.baseUnit = 'Base Unit',
    this.purchaseUnit = 'Purchase Unit',
    this.brand,
    this.daysInExpiry = 0,
    this.status = 'Active',
    this.notes,
    this.deleted = false,
    this.synced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'margin': margin,
      'category_id': categoryId,
      'category_name': categoryName,
      'opening_stock': openingStock,
      'cost': cost,
      'price': price,
      'alert_qty': alertQty,
      'location': location,
      'sale_unit': saleUnit,
      'extra_units': extraUnits,
      'base_unit': baseUnit,
      'purchase_unit': purchaseUnit,
      'brand': brand,
      'days_in_expiry': daysInExpiry,
      'status': status,
      'notes': notes,
      'deleted': deleted,
      'synced': synced,
    };
  }

  static double _parseToDouble(dynamic val, [double defaultVal = 0.0]) {
    if (val == null) return defaultVal;
    if (val is int) return val.toDouble();
    if (val is double) return val;
    if (val is String) return double.tryParse(val) ?? defaultVal;
    return defaultVal;
  }

  factory ProductModel.fromMap(Map<dynamic, dynamic> map) {
    return ProductModel(
      id: map['id'] as String,
      name: map['name'] as String,
      sku: map['sku'] as String?,
      margin: _parseToDouble(map['margin']),
      categoryId: map['category_id'] as String?,
      categoryName: map['category_name'] as String?,
      openingStock: _parseToDouble(map['opening_stock']),
      cost: _parseToDouble(map['cost']),
      price: _parseToDouble(map['price']),
      alertQty: _parseToDouble(map['alert_qty'], 1.0),
      location: map['location'] as String? ?? 'Default',
      saleUnit: map['sale_unit'] as String? ?? 'Sale Unit',
      extraUnits: map['extra_units'] as String? ?? 'Extra Units',
      baseUnit: map['base_unit'] as String? ?? 'Base Unit',
      purchaseUnit: map['purchase_unit'] as String? ?? 'Purchase Unit',
      brand: map['brand'] as String?,
      daysInExpiry: map['days_in_expiry'] as int? ?? 0,
      status: map['status'] as String? ?? 'Active',
      notes: map['notes'] as String?,
      deleted: map['deleted'] == true || map['deleted'] == 1,
      synced: map['synced'] == true || map['synced'] == 1,
    );
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? sku,
    double? margin,
    String? categoryId,
    String? categoryName,
    double? openingStock,
    double? cost,
    double? price,
    double? alertQty,
    String? location,
    String? saleUnit,
    String? extraUnits,
    String? baseUnit,
    String? purchaseUnit,
    String? brand,
    int? daysInExpiry,
    String? status,
    String? notes,
    bool? deleted,
    bool? synced,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      margin: margin ?? this.margin,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      openingStock: openingStock ?? this.openingStock,
      cost: cost ?? this.cost,
      price: price ?? this.price,
      alertQty: alertQty ?? this.alertQty,
      location: location ?? this.location,
      saleUnit: saleUnit ?? this.saleUnit,
      extraUnits: extraUnits ?? this.extraUnits,
      baseUnit: baseUnit ?? this.baseUnit,
      purchaseUnit: purchaseUnit ?? this.purchaseUnit,
      brand: brand ?? this.brand,
      daysInExpiry: daysInExpiry ?? this.daysInExpiry,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      deleted: deleted ?? this.deleted,
      synced: synced ?? this.synced,
    );
  }
}
