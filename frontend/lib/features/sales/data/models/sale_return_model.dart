class SaleReturnItemModel {
  final String productName;
  final int qty;
  final double price;
  final double totalPrice;

  SaleReturnItemModel({
    required this.productName,
    required this.qty,
    required this.price,
    required this.totalPrice,
  });

  factory SaleReturnItemModel.fromMap(Map<String, dynamic> map) {
    return SaleReturnItemModel(
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

class SaleReturnModel {
  final String id;
  final String? saleId;
  final String returnNo;
  final String returnDate;
  final double totalAmount;
  final String? reason;
  final List<SaleReturnItemModel> items;

  SaleReturnModel({
    required this.id,
    this.saleId,
    required this.returnNo,
    required this.returnDate,
    required this.totalAmount,
    this.reason,
    required this.items,
  });

  factory SaleReturnModel.fromMap(Map<String, dynamic> map) {
    return SaleReturnModel(
      id: map['id'] ?? '',
      saleId: map['sale'] ?? map['saleId'],
      returnNo: map['return_no'] ?? map['returnNo'] ?? '',
      returnDate: map['return_date'] ?? map['returnDate'] ?? DateTime.now().toIso8601String(),
      totalAmount: double.tryParse(map['total_amount']?.toString() ?? '0.0') ?? 0.0,
      reason: map['reason'],
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => SaleReturnItemModel.fromMap(Map<String, dynamic>.from(item)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale': saleId,
      'return_no': returnNo,
      'return_date': returnDate,
      'total_amount': totalAmount,
      'reason': reason,
      'items': items.map((e) => e.toMap()).toList(),
    };
  }
}
