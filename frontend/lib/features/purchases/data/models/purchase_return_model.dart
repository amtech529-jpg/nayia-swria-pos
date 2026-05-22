class PurchaseReturnItemModel {
  final String productName;
  final int qty;
  final double price;
  final double totalPrice;

  PurchaseReturnItemModel({
    required this.productName,
    required this.qty,
    required this.price,
    required this.totalPrice,
  });

  factory PurchaseReturnItemModel.fromMap(Map<String, dynamic> map) {
    return PurchaseReturnItemModel(
      productName: map['product_name'] ?? map['productName'] ?? '',
      qty: map['qty'] ?? 1,
      price: double.tryParse(map['price']?.toString() ?? '0.0') ?? 0.0,
      totalPrice: double.tryParse(map['total_price']?.toString() ?? '0.0') ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_name': productName,
      'qty': qty,
      'price': price,
      'total_price': totalPrice,
    };
  }
}

class PurchaseReturnModel {
  final String id;
  final String? purchaseId;
  final String returnNo;
  final String returnDate;
  final double totalAmount;
  final String? reason;
  final List<PurchaseReturnItemModel> items;

  PurchaseReturnModel({
    required this.id,
    this.purchaseId,
    required this.returnNo,
    required this.returnDate,
    required this.totalAmount,
    this.reason,
    required this.items,
  });

  factory PurchaseReturnModel.fromMap(Map<String, dynamic> map) {
    return PurchaseReturnModel(
      id: map['id'] ?? '',
      purchaseId: map['purchase'] ?? map['purchaseId'],
      returnNo: map['return_no'] ?? map['returnNo'] ?? '',
      returnDate: map['return_date'] ?? map['returnDate'] ?? DateTime.now().toIso8601String(),
      totalAmount: double.tryParse(map['total_amount']?.toString() ?? '0.0') ?? 0.0,
      reason: map['reason'],
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => PurchaseReturnItemModel.fromMap(Map<String, dynamic>.from(item)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'purchase': purchaseId,
      'return_no': returnNo,
      'return_date': returnDate,
      'total_amount': totalAmount,
      'reason': reason,
      'items': items.map((e) => e.toMap()).toList(),
    };
  }
}
