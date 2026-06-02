class SaleDetail {
  final int    id;
  final int    productId;
  final String productName;
  final int    quantity;
  final double price;
  final double subtotal;

  const SaleDetail({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory SaleDetail.fromJson(Map<String, dynamic> json) => SaleDetail(
    id:          json['id'] ?? 0,
    productId:   json['product'],
    productName: json['product_name'] ?? '',
    quantity:    json['quantity'],
    price:       double.parse(json['price'].toString()),
    subtotal:    double.parse(json['subtotal'].toString()),
  );

  Map<String, dynamic> toJson() => {
    'product':  productId,
    'quantity': quantity,
    'price':    price,
    'subtotal': subtotal,
  };

  factory SaleDetail.fromMap(Map<String, dynamic> map) => SaleDetail(
    id:          map['id'] ?? 0,
    productId:   map['product_id'] ?? 0,
    productName: map['product_name'] ?? '',
    quantity:    map['quantity'] ?? 0,
    price:       double.parse(map['price'].toString()),
    subtotal:    double.parse(map['subtotal'].toString()),
  );
}

class Sale {
  final int              id;
  final int              clientId;
  final String?          clientName;
  final String?          createdAt;
  final double           subtotal;
  final double           igv;
  final double           total;
  final List<SaleDetail> details;
  final bool             isSynced;
  final int?             serverId;

  const Sale({
    required this.id,
    required this.clientId,
    this.clientName,
    this.createdAt,
    required this.subtotal,
    required this.igv,
    required this.total,
    this.details = const [],
    this.isSynced = false,
    this.serverId,
  });

  factory Sale.fromJson(Map<String, dynamic> json) => Sale(
    id:         json['id'] ?? 0,
    clientId:   json['client'],
    clientName: json['client_name'],
    createdAt:  json['created_at'],
    subtotal:   double.parse(json['subtotal'].toString()),
    igv:        double.parse(json['igv'].toString()),
    total:      double.parse(json['total'].toString()),
    details: (json['details'] as List<dynamic>? ?? [])
        .map((d) => SaleDetail.fromJson(d))
        .toList(),
    isSynced: true,
    serverId: json['id'],
  );


  Map<String, dynamic> toJson() => {
    'client':   clientId,
    'subtotal': subtotal,
    'igv':      igv,
    'total':    total,
    'details':  details.map((d) => d.toJson()).toList(),
  };

  factory Sale.fromMap(Map<String, dynamic> map) {
    // Leer detalles desde el campo 'details' agregado por getAllSalesWithDetails()
    final List<SaleDetail> saleDetails = [];
    final rawDetails = map['details'];
    if (rawDetails is List) {
      for (final d in rawDetails) {
        final dm = Map<String, dynamic>.from(d as Map);
        saleDetails.add(SaleDetail.fromMap(dm));
      }
    }

    return Sale(
      id:         map['id'],
      clientId:   map['client_id'],
      clientName: map['client_name'],
      createdAt:  map['date'],
      subtotal:   double.parse(map['subtotal'].toString()),
      igv:        double.parse(map['igv'].toString()),
      total:      double.parse(map['total'].toString()),
      details:    saleDetails,
      isSynced:   map['is_synced'] == 1,
      serverId:   map['server_id'],
    );
  }

  Map<String, dynamic> toMap() => {
    if (id != 0) 'id': id,
    'client_id':   clientId,
    'client_name': clientName,
    'subtotal':    subtotal,
    'igv':         igv,
    'total':       total,
    'date':        createdAt,
    'is_synced':   isSynced ? 1 : 0,
    'server_id':   serverId,
  };
}