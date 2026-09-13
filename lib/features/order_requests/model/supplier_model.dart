class Supplier {
  final String id;
  final String companyName;
  final String companyLogo;
  final String description;
  final String address;
  final String phone;
  final String email;
  final double rating;
  final int totalOrders;
  final int successfulDeliveries;
  final String responseTime;
  final bool isVerified;
  final bool coldChainCompliant;

  const Supplier({
    required this.id,
    required this.companyName,
    required this.companyLogo,
    required this.description,
    required this.address,
    required this.phone,
    required this.email,
    required this.rating,
    required this.totalOrders,
    required this.successfulDeliveries,
    required this.responseTime,
    required this.isVerified,
    required this.coldChainCompliant,
  });

  double get deliverySuccessRate {
    if (totalOrders == 0) return 0;

    return (successfulDeliveries / totalOrders) * 100;
  }
}
