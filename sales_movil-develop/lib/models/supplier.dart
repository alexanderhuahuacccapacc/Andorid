class Supplier {
  final int    id;
  final String name;
  final String documentNumber;
  final String email;
  final String phone;
  final String address;
  final bool   isSynced;
  final int?   serverId;

  Supplier(
      this.id,
      this.name,
      this.documentNumber,
      this.email,
      this.phone,
      this.address,
      this.isSynced,
      this.serverId,
      );

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      map['id'],
      map['name'].toString(),
      map['document_number'].toString(),
      map['email'].toString(),
      map['phone'].toString(),
      map['address'].toString(),
      map['is_synced'] == 1,
      map['server_id'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != 0) 'id': id,
      'name':            name,
      'document_number': documentNumber,
      'email':           email,
      'phone':           phone,
      'address':         address,
      'is_synced':       isSynced ? 1 : 0,
      'server_id':       serverId,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'name':            name,
      'document_number': documentNumber,
      'email':           email,
      'phone':           phone,
      'address':         address,
    };
  }

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      json['id'] ?? 0,
      json['name'].toString(),
      json['document_number'].toString(),
      json['email'].toString(),
      json['phone'].toString(),
      json['address'].toString(),
      false,
      json['id'] as int?,
    );
  }
}