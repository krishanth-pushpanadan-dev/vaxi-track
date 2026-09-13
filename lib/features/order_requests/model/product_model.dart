class Product {
  final String id;
  final String name;
  final String category;
  final String manufacturer;
  final String description;
  final String imageUrl;
  final int availableQuantity;
  final String unit;
  final int minimumOrderQuantity;
  final double price;
  final String storageTemperature;
  final DateTime expiryDate;
  final String supplierId;
  final String supplierName;
  final bool isAvailable;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.manufacturer,
    required this.description,
    required this.imageUrl,
    required this.availableQuantity,
    required this.unit,
    required this.minimumOrderQuantity,
    required this.price,
    required this.storageTemperature,
    required this.expiryDate,
    required this.supplierId,
    required this.supplierName,
    required this.isAvailable,
  });

  bool get isLowStock => availableQuantity <= 20;

  bool get isExpired => expiryDate.isBefore(DateTime.now());

  bool get isExpiringSoon {
    final difference = expiryDate.difference(DateTime.now()).inDays;
    return difference >= 0 && difference <= 30;
  }
}
