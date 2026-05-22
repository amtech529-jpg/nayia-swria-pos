class SaleItemModel {
  final int? id;
  final String productName;
  final String? sku;
  final int qty;
  final double price;
  final double discount;
  final double totalPrice;

  SaleItemModel({
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

  factory SaleItemModel.fromMap(Map<dynamic, dynamic> map) {
    return SaleItemModel(
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

class SaleModel {
  final String id;
  final String invoiceNo;
  final String? customerId;
  final String? customerName;
  final String location;
  final String? refNo;
  final String saleDate;
  final double subtotal;
  final double discount;
  final double netTotal;
  final double paidAmount;
  final double pendingAmount;
  final String paymentMethod;
  final String? notes;
  final bool deleted;
  final bool synced;
  final List<SaleItemModel> items;

  SaleModel({
    required this.id,
    required this.invoiceNo,
    this.customerId,
    this.customerName,
    this.location = 'Default',
    this.refNo,
    required this.saleDate,
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
      'customer': customerId,
      'customer_name': customerName,
      'location': location,
      'ref_no': refNo,
      'sale_date': saleDate,
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

  factory SaleModel.fromMap(Map<dynamic, dynamic> map) {
    return SaleModel(
      id: map['id'] as String? ?? '',
      invoiceNo: map['invoice_no'] as String? ?? '',
      customerId: map['customer'] as String?,
      customerName: map['customer_name'] as String?,
      location: map['location'] as String? ?? 'Default',
      refNo: map['ref_no'] as String?,
      saleDate: map['sale_date'] as String? ?? DateTime.now().toIso8601String(),
      subtotal: SaleItemModel._parseToDouble(map['subtotal']),
      discount: SaleItemModel._parseToDouble(map['discount']),
      netTotal: SaleItemModel._parseToDouble(map['net_total']),
      paidAmount: SaleItemModel._parseToDouble(map['paid_amount']),
      pendingAmount: SaleItemModel._parseToDouble(map['pending_amount']),
      paymentMethod: map['payment_method'] as String? ?? 'Cash',
      notes: map['notes'] as String?,
      deleted: map['deleted'] == true || map['deleted'] == 1,
      synced: map['synced'] == true || map['synced'] == 1,
      items: map['items'] != null
          ? List<SaleItemModel>.from((map['items'] as List).map((x) => SaleItemModel.fromMap(x as Map)))
          : [],
    );
  }

  SaleModel copyWith({
    String? id,
    String? invoiceNo,
    String? customerId,
    String? customerName,
    String? location,
    String? refNo,
    String? saleDate,
    double? subtotal,
    double? discount,
    double? netTotal,
    double? paidAmount,
    double? pendingAmount,
    String? paymentMethod,
    String? notes,
    bool? deleted,
    bool? synced,
    List<SaleItemModel>? items,
  }) {
    return SaleModel(
      id: id ?? this.id,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      location: location ?? this.location,
      refNo: refNo ?? this.refNo,
      saleDate: saleDate ?? this.saleDate,
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
