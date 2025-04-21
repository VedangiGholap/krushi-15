class PricingService {
  /// Calculates dynamic price adjustment based on age and stock level
  static double calculateDynamicPrice({
    required double cp,
    required double msp,
    required int age,           // In days
    required double stockLevel, // 0.0 to 1.0
  }) {
    final basePrice = cp > msp ? cp : msp;

    double dpAge = 0;
    if (age >= 3 && age <= 5) {
      dpAge = -0.05 * basePrice;
    } else if (age > 5 && age < 7) {
      dpAge = -0.10 * basePrice;
    } else if (age >= 7) {
      throw Exception('Produce needs to be repriced');
    }

    double dpStock = 0;
    if (stockLevel <= 0.25) {
      dpStock = -0.10 * basePrice;
    } else if (stockLevel <= 0.5) {
      dpStock = -0.05 * basePrice;
    }

    return dpAge + dpStock;
  }

  /// Decides if a customer bid should be accepted
  static bool shouldAcceptBid({
    required double customerBid,
    required double cp,
    required double msp,
    required double dynamicPrice,
  }) {
    final basePrice = cp > msp ? cp : msp;
    final sp = basePrice + dynamicPrice;
    return customerBid >= sp;
  }

  /// Calculate recommended price (SP)
  static double getRecommendedPrice({
    required double cp,
    required double msp,
    required double dynamicPrice,
  }) {
    final basePrice = cp > msp ? cp : msp;
    return basePrice + dynamicPrice;
  }

  /// Calculate minimum price
  static double calculateMinimumPrice({
    required double cp,
    required double msp,
  }) {
    return cp < msp ? cp : msp;
  }
}
