import 'package:equatable/equatable.dart';

import '../entities/cart_line.dart';

/// Result of a stock validation evaluation.
class StockValidationResult extends Equatable {
  final bool isValid;
  final String? message;
  final int remainingStock;
  final int? failedId;
  final bool isAddon;

  const StockValidationResult.valid({this.remainingStock = 0})
      : isValid = true,
        message = null,
        failedId = null,
        isAddon = false;

  const StockValidationResult.invalid({
    required this.message,
    required this.remainingStock,
    this.failedId,
    this.isAddon = false,
  }) : isValid = false;

  @override
  List<Object?> get props => [isValid, message, remainingStock, failedId, isAddon];
}

/// Evaluates stock usage across cart lines according to Rule 1 (Shared Stock Validation).
///
/// Rules:
/// 1. Product units used = sum of `qty` over every cart line with the same `productId`.
/// 2. Add-on units used = sum over lines of (`line.qty` x number of that add-on attached to the line).
/// 3. Returns detailed results with failure explanation and remaining stock count.
class StockValidator {
  const StockValidator();

  /// Calculates total units of [productId] currently consumed by [cart].
  int calculateProductUsage(Iterable<CartLine> cart, int productId) {
    var total = 0;
    for (final line in cart) {
      if (line.productId == productId) {
        total += line.qty;
      }
    }
    return total;
  }

  /// Calculates total units of [addonId] currently consumed by [cart].
  /// Formula: sum over lines of (line.qty * count of that addon on that line).
  int calculateAddonUsage(Iterable<CartLine> cart, int addonId) {
    var total = 0;
    for (final line in cart) {
      final count = line.addons.where((a) => a.id == addonId).length;
      total += line.qty * count;
    }
    return total;
  }

  /// Validates adding [qtyToAdd] units of [productId] with [addons] to [currentCart].
  StockValidationResult validateAdd({
    required Iterable<CartLine> currentCart,
    required int productId,
    String? productName,
    required int availableProductStock,
    int qtyToAdd = 1,
    List<CartAddon> addons = const [],
    Map<int, int> addonStocks = const {},
  }) {
    final pName = productName ?? 'Produk';

    if (availableProductStock <= 0) {
      return StockValidationResult.invalid(
        message: 'Stok $pName habis. Tersisa 0.',
        remainingStock: 0,
        failedId: productId,
        isAddon: false,
      );
    }

    final currentProductUsage = calculateProductUsage(currentCart, productId);
    final remainingProductStock = availableProductStock - currentProductUsage;

    if (currentProductUsage + qtyToAdd > availableProductStock) {
      final safeRemaining =
          remainingProductStock < 0 ? 0 : remainingProductStock;
      return StockValidationResult.invalid(
        message: 'Stok tidak cukup. Tersisa $safeRemaining.',
        remainingStock: safeRemaining,
        failedId: productId,
        isAddon: false,
      );
    }

    // Check stock for each attached addon
    for (final addon in addons) {
      final addonCountInLine = addons.where((a) => a.id == addon.id).length;
      final additionalAddonUsage = qtyToAdd * addonCountInLine;
      final currentAddonUsage = calculateAddonUsage(currentCart, addon.id);
      final availableAddonStock = addonStocks[addon.id] ?? 0;
      final remainingAddonStock = availableAddonStock - currentAddonUsage;

      if (availableAddonStock <= 0) {
        return StockValidationResult.invalid(
          message: 'Stok add-on ${addon.name} habis. Tersisa 0.',
          remainingStock: 0,
          failedId: addon.id,
          isAddon: true,
        );
      }

      if (currentAddonUsage + additionalAddonUsage > availableAddonStock) {
        final safeRemaining =
            remainingAddonStock < 0 ? 0 : remainingAddonStock;
        return StockValidationResult.invalid(
          message: 'Stok add-on ${addon.name} tidak cukup. Tersisa $safeRemaining.',
          remainingStock: safeRemaining,
          failedId: addon.id,
          isAddon: true,
        );
      }
    }

    return StockValidationResult.valid(
      remainingStock: remainingProductStock - qtyToAdd,
    );
  }

  /// Validates changing quantity of [targetLine] in [currentCart] to [newQty].
  /// Downward adjustments (`newQty <= targetLine.qty`) are always allowed.
  /// Upward adjustments check the delta against available product and add-on stock.
  StockValidationResult validateUpdateQty({
    required Iterable<CartLine> currentCart,
    required CartLine targetLine,
    required int newQty,
    required int availableProductStock,
    Map<int, int> addonStocks = const {},
  }) {
    if (newQty < 0) {
      return const StockValidationResult.invalid(
        message: 'Jumlah tidak valid.',
        remainingStock: 0,
      );
    }

    final currentProductUsage =
        calculateProductUsage(currentCart, targetLine.productId);

    // Downward adjustment: always permitted
    if (newQty <= targetLine.qty) {
      final newUsage = currentProductUsage - targetLine.qty + newQty;
      return StockValidationResult.valid(
        remainingStock: availableProductStock - newUsage,
      );
    }

    // Upward adjustment
    final delta = newQty - targetLine.qty;
    final remainingProductStock = availableProductStock - currentProductUsage;

    if (currentProductUsage + delta > availableProductStock) {
      final safeRemaining =
          remainingProductStock < 0 ? 0 : remainingProductStock;
      return StockValidationResult.invalid(
        message: 'Stok tidak cukup. Tersisa $safeRemaining.',
        remainingStock: safeRemaining,
        failedId: targetLine.productId,
        isAddon: false,
      );
    }

    // Validate addons for upward delta
    for (final addon in targetLine.addons) {
      final addonCount =
          targetLine.addons.where((a) => a.id == addon.id).length;
      final deltaAddon = delta * addonCount;
      final currentAddonUsage = calculateAddonUsage(currentCart, addon.id);
      final availableAddonStock = addonStocks[addon.id] ?? 0;
      final remainingAddonStock = availableAddonStock - currentAddonUsage;

      if (currentAddonUsage + deltaAddon > availableAddonStock) {
        final safeRemaining =
            remainingAddonStock < 0 ? 0 : remainingAddonStock;
        return StockValidationResult.invalid(
          message: 'Stok add-on ${addon.name} tidak cukup. Tersisa $safeRemaining.',
          remainingStock: safeRemaining,
          failedId: addon.id,
          isAddon: true,
        );
      }
    }

    final newUsage = currentProductUsage + delta;
    return StockValidationResult.valid(
      remainingStock: availableProductStock - newUsage,
    );
  }

  /// Validates the entirety of [cart] against product and addon stock records.
  StockValidationResult validateCart({
    required Iterable<CartLine> cart,
    required Map<int, int> productStocks,
    Map<int, int> addonStocks = const {},
    Map<int, String> productNames = const {},
    Map<int, String> addonNames = const {},
  }) {
    // Check product usage
    final checkedProductIds = <int>{};
    for (final line in cart) {
      if (checkedProductIds.add(line.productId)) {
        final usage = calculateProductUsage(cart, line.productId);
        final stock = productStocks[line.productId] ?? 0;
        if (usage > stock) {
          final name = productNames[line.productId] ?? line.productName;
          return StockValidationResult.invalid(
            message: stock <= 0
                ? 'Stok $name habis. Tersisa 0.'
                : 'Stok tidak cukup. Tersisa $stock.',
            remainingStock: stock,
            failedId: line.productId,
            isAddon: false,
          );
        }
      }
    }

    // Check addon usage
    final checkedAddonIds = <int>{};
    for (final line in cart) {
      for (final addon in line.addons) {
        if (checkedAddonIds.add(addon.id)) {
          final usage = calculateAddonUsage(cart, addon.id);
          final stock = addonStocks[addon.id] ?? 0;
          if (usage > stock) {
            final name = addonNames[addon.id] ?? addon.name;
            return StockValidationResult.invalid(
              message: stock <= 0
                  ? 'Stok add-on $name habis. Tersisa 0.'
                  : 'Stok add-on $name tidak cukup. Tersisa $stock.',
              remainingStock: stock,
              failedId: addon.id,
              isAddon: true,
            );
          }
        }
      }
    }

    return const StockValidationResult.valid();
  }
}
