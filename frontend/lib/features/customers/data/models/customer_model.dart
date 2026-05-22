class CustomerModel {
  final String id;
  final String name;
  final String? fatherName;
  final String? phone;
  final String? email;
  final String? cnic;
  final String? address;
  final String location;
  final String area;
  final double balance;
  final String? imageUrl;
  final bool deleted;
  final bool synced;

  CustomerModel({
    required this.id,
    required this.name,
    this.fatherName,
    this.phone,
    this.email,
    this.cnic,
    this.address,
    this.location = 'Default',
    this.area = 'None',
    this.balance = 0.0,
    this.imageUrl,
    this.deleted = false,
    this.synced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'father_name': fatherName,
      'phone': phone,
      'email': email,
      'cnic': cnic,
      'address': address,
      'location': location,
      'area': area,
      'balance': balance,
      'image_url': imageUrl,
      'deleted': deleted,
      'synced': synced,
    };
  }

  factory CustomerModel.fromMap(Map<dynamic, dynamic> map) {
    return CustomerModel(
      id: map['id'] as String,
      name: map['name'] as String,
      fatherName: map['father_name'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      cnic: map['cnic'] as String?,
      address: map['address'] as String?,
      location: map['location'] as String? ?? 'Default',
      area: map['area'] as String? ?? 'None',
      balance: double.tryParse(map['balance']?.toString() ?? '0') ?? 0.0,
      imageUrl: map['image_url'] as String?,
      deleted: map['deleted'] == true || map['deleted'] == 1,
      synced: map['synced'] == true || map['synced'] == 1,
    );
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? fatherName,
    String? phone,
    String? email,
    String? cnic,
    String? address,
    String? location,
    String? area,
    double? balance,
    String? imageUrl,
    bool? deleted,
    bool? synced,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      fatherName: fatherName ?? this.fatherName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      cnic: cnic ?? this.cnic,
      address: address ?? this.address,
      location: location ?? this.location,
      area: area ?? this.area,
      balance: balance ?? this.balance,
      imageUrl: imageUrl ?? this.imageUrl,
      deleted: deleted ?? this.deleted,
      synced: synced ?? this.synced,
    );
  }
}
