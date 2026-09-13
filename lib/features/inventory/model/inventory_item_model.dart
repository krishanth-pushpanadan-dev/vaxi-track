class InventoryItem {
  final String id;
  final String vaccineName;
  final String batchNumber;
  final int totalDoses;
  final int availableDoses;
  final String storageLocation;
  final DateTime expiryDate;

  const InventoryItem({
    required this.id,
    required this.vaccineName,
    required this.batchNumber,
    required this.totalDoses,
    required this.availableDoses,
    required this.storageLocation,
    required this.expiryDate,
  });

  int get usedDoses => totalDoses - availableDoses;

  double get stockPercentage {
    if (totalDoses == 0) return 0;
    return availableDoses / totalDoses;
  }

  bool get isOutOfStock => availableDoses <= 0;

  bool get isLowStock => stockPercentage <= 0.20;

  bool get isExpired => expiryDate.isBefore(DateTime.now());

  bool get isExpiringSoon {
    final difference = expiryDate.difference(DateTime.now()).inDays;
    return difference >= 0 && difference <= 30;
  }
}
