class SupplierModel {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String location;
  final double purchaseTotal;
  final bool deleted;
  final bool synced;

  SupplierModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.location = 'Default',
    this.purchaseTotal = 0.0,
    this.deleted = false,
    this.synced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'location': location,
      'purchase_total': purchaseTotal,
      'deleted': deleted,
      'synced': synced,
    };
  }

  factory SupplierModel.fromMap(Map<dynamic, dynamic> map) {
    return SupplierModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      location: map['location'] as String? ?? 'Default',
      purchaseTotal: double.tryParse(map['purchase_total']?.toString() ?? '0') ?? 0.0,
      deleted: map['deleted'] == true || map['deleted'] == 1,
      synced: map['synced'] == true || map['synced'] == 1,
    );
  }
}
