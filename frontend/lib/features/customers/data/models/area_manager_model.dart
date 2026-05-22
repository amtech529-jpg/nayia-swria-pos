class AreaManagerModel {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String area;
  final double balance;
  final String status;
  final bool deleted;
  final bool synced;

  AreaManagerModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.area = 'None',
    this.balance = 0.0,
    this.status = 'Active',
    this.deleted = false,
    this.synced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'area': area,
      'balance': balance,
      'status': status,
      'deleted': deleted,
      'synced': synced,
    };
  }

  factory AreaManagerModel.fromMap(Map<dynamic, dynamic> map) {
    return AreaManagerModel(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      area: map['area'] as String? ?? 'None',
      balance: double.tryParse(map['balance']?.toString() ?? '0') ?? 0.0,
      status: map['status'] as String? ?? 'Active',
      deleted: map['deleted'] == true || map['deleted'] == 1,
      synced: map['synced'] == true || map['synced'] == 1,
    );
  }

  AreaManagerModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? area,
    double? balance,
    String? status,
    bool? deleted,
    bool? synced,
  }) {
    return AreaManagerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      area: area ?? this.area,
      balance: balance ?? this.balance,
      status: status ?? this.status,
      deleted: deleted ?? this.deleted,
      synced: synced ?? this.synced,
    );
  }
}
