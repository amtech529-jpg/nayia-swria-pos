class PurchaseItemModel {
  final int? id;
  final String productName;
  final String? sku;
  final int qty;
  final double price;
  final double discount;
  final double totalPrice;

  PurchaseItemModel({
    this.id,
    required this.productName,
    this.sku,
    required this.qty,
    required this.price,
    this.discount = 0.0,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'product_name': productName,
      'sku': sku,
      'qty': qty,
      'price': price,
      'discount': discount,
      'total_price': totalPrice,
    };
  }

  factory PurchaseItemModel.fromMap(Map<dynamic, dynamic> map) {
    return PurchaseItemModel(
      id: map['id'] as int?,
      productName: map['product_name'] as String? ?? '',
      sku: map['sku'] as String?,
      qty: map['qty'] as int? ?? 1,
      price: _parseToDouble(map['price']),
      discount: _parseToDouble(map['discount']),
      totalPrice: _parseToDouble(map['total_price']),
    );
  }

  static double _parseToDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is int) return val.toDouble();
    if (val is double) return val;
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }
}

class PurchaseModel {
  final String id;
  final String invoiceNo;
  final String? supplierId;
  final String? supplierName;
  final String location;
  final String? refNo;
  final String purchaseDate;
  final double subtotal;
  final double discount;
  final double netTotal;
  final double paidAmount;
  final double pendingAmount;
  final String paymentMethod;
  final String? notes;
  final bool deleted;
  final bool synced;
  final List<PurchaseItemModel> items;

  PurchaseModel({
    required this.id,
    required this.invoiceNo,
    this.supplierId,
    this.supplierName,
    this.location = 'Default',
    this.refNo,
    required this.purchaseDate,
    required this.subtotal,
    this.discount = 0.0,
    required this.netTotal,
    this.paidAmount = 0.0,
    required this.pendingAmount,
    this.paymentMethod = 'Cash',
    this.notes,
    this.deleted = false,
    this.synced = false,
    this.items = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_no': invoiceNo,
      'supplier': supplierId,
      'supplier_name': supplierName,
      'location': location,
      'ref_no': refNo,
      'purchase_date': purchaseDate,
      'subtotal': subtotal,
      'discount': discount,
      'net_total': netTotal,
      'paid_amount': paidAmount,
      'pending_amount': pendingAmount,
      'payment_method': paymentMethod,
      'notes': notes,
      'deleted': deleted,
      'synced': synced,
      'items': items.map((x) => x.toMap()).toList(),
    };
  }

  factory PurchaseModel.fromMap(Map<dynamic, dynamic> map) {
    return PurchaseModel(
      id: map['id'] as String? ?? '',
      invoiceNo: map['invoice_no'] as String? ?? '',
      supplierId: map['supplier'] as String?,
      supplierName: map['supplier_name'] as String?,
      location: map['location'] as String? ?? 'Default',
      refNo: map['ref_no'] as String?,
      purchaseDate: map['purchase_date'] as String? ?? DateTime.now().toIso8601String(),
      subtotal: PurchaseItemModel._parseToDouble(map['subtotal']),
      discount: PurchaseItemModel._parseToDouble(map['discount']),
      netTotal: PurchaseItemModel._parseToDouble(map['net_total']),
      paidAmount: PurchaseItemModel._parseToDouble(map['paid_amount']),
      pendingAmount: PurchaseItemModel._parseToDouble(map['pending_amount']),
      paymentMethod: map['payment_method'] as String? ?? 'Cash',
      notes: map['notes'] as String?,
      deleted: map['deleted'] == true || map['deleted'] == 1,
      synced: map['synced'] == true || map['synced'] == 1,
      items: map['items'] != null
          ? List<PurchaseItemModel>.from((map['items'] as List).map((x) => PurchaseItemModel.fromMap(x as Map)))
          : [],
    );
  }

  PurchaseModel copyWith({
    String? id,
    String? invoiceNo,
    String? supplierId,
    String? supplierName,
    String? location,
    String? refNo,
    String? purchaseDate,
    double? subtotal,
    double? discount,
    double? netTotal,
    double? paidAmount,
    double? pendingAmount,
    String? paymentMethod,
    String? notes,
    bool? deleted,
    bool? synced,
    List<PurchaseItemModel>? items,
  }) {
    return PurchaseModel(
      id: id ?? this.id,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      location: location ?? this.location,
      refNo: refNo ?? this.refNo,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      netTotal: netTotal ?? this.netTotal,
      paidAmount: paidAmount ?? this.paidAmount,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      deleted: deleted ?? this.deleted,
      synced: synced ?? this.synced,
      items: items ?? this.items,
    );
  }
}
