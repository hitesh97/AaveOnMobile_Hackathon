class AavePool {
  final double ltv,
      availableLiquidity,
      averageStableBorrowRate,
      liquidationPenality,
      liquidationThreshold,
      liquidityRate,
      spot,
      stableBorrowRate,
      totalStableDebt,
      totalVariableDebt,
      decimals,
      variableBorrowRate;

  final bool canBorrow,
      canUseAsCollateral,
      isActive,
      isFrozen,
      stableBorrowRateEnabled;

  final String ltvDescription,
      ltvThresholdDescription,
      img,
      symbol,
      penalityDescription;

  const AavePool(
      {this.availableLiquidity,
      this.averageStableBorrowRate,
      this.canBorrow,
      this.canUseAsCollateral,
      this.decimals,
      this.symbol,
      this.img,
      this.isActive,
      this.isFrozen,
      this.liquidationPenality,
      this.liquidationThreshold,
      this.liquidityRate,
      this.ltv,
      this.ltvDescription,
      this.ltvThresholdDescription,
      this.penalityDescription,
      this.spot,
      this.stableBorrowRate,
      this.stableBorrowRateEnabled,
      this.totalStableDebt,
      this.totalVariableDebt,
      this.variableBorrowRate});

  AavePool.fromMap(Map<dynamic, dynamic> data)
      : this(
          availableLiquidity: data["availableLiquidity"].toDouble(),
          averageStableBorrowRate: data["averageStableBorrowRate"].toDouble(),
          canBorrow: data["canBorrow"],
          canUseAsCollateral: data["canUseAsCollateral"],
          decimals: data["decimals"].toDouble(),
          isActive: data["isActive"],
          isFrozen: data["isFrozen"],
          liquidationPenality: data["liquidation_penalty"].toDouble(),
          liquidationThreshold: data["liquidation_threshold"].toDouble(),
          liquidityRate: data["liquidityRate"].toDouble(),
          ltv: data["LTV"].toDouble(),
          symbol: data["symbol"],
          ltvDescription: data["LTV_desc"],
          ltvThresholdDescription: data["LTC_threshold_desc"],
          penalityDescription: data["penalty_desc"],
          spot: data["spot"].toDouble(),
          stableBorrowRate: data["stableBorrowRate"].toDouble(),
          stableBorrowRateEnabled: data["stableBorrowRateEnabled"],
          totalStableDebt: data["totalStableDebt"].toDouble(),
          totalVariableDebt: data["totalVariableDebt"].toDouble(),
          variableBorrowRate: data["variableBorrowRate"].toDouble(),
          img: data["img"],
        );
}
