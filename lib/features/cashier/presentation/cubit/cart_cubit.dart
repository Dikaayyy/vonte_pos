import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../addon/domain/entities/addon.dart';
import '../../../addon/domain/usecases/get_addon_by_id.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/domain/usecases/get_product_by_id.dart';
import '../../domain/entities/cart_line.dart';
import '../../domain/entities/cart_totals.dart';
import '../../domain/entities/discount.dart';
import '../../domain/validators/discount_calculator.dart';
import '../../domain/validators/stock_validator.dart';
import 'cart_state.dart';

/// Cubit managing cashier shopping cart state, stock validation, and totals.
class CartCubit extends Cubit<CartState> {
  final GetProductById getProductById;
  final GetAddonById getAddonById;
  final StockValidator stockValidator;
  final DiscountCalculator discountCalculator;

  CartCubit({
    required this.getProductById,
    required this.getAddonById,
    this.stockValidator = const StockValidator(),
    this.discountCalculator = const DiscountCalculator(),
  }) : super(const CartState());

  /// Adds a product with optional attached add-ons into the cart.
  /// Validates stock usage according to Rule 1 (Shared Stock Validation).
  Future<void> addProduct(
    Product product, {
    List<CartAddon> addons = const [],
    int qty = 1,
  }) async {
    if (qty <= 0) return;

    try {
      final latestProduct = await getProductById(product.id);
      if (latestProduct == null || latestProduct.isDeleted) {
        emit(state.copyWith(
          errorMessage: 'Produk ${product.name} tidak ditemukan atau sudah tidak aktif.',
        ));
        return;
      }

      final addonStocks = <int, int>{};
      for (final addon in addons) {
        if (!addonStocks.containsKey(addon.id)) {
          final latestAddon = await getAddonById(addon.id);
          if (latestAddon == null || latestAddon.isDeleted) {
            emit(state.copyWith(
              errorMessage:
                  'Add-on ${addon.name} tidak ditemukan atau sudah tidak aktif.',
            ));
            return;
          }
          addonStocks[addon.id] = latestAddon.stock;
        }
      }

      final validation = stockValidator.validateAdd(
        currentCart: state.items,
        productId: latestProduct.id,
        productName: latestProduct.name,
        availableProductStock: latestProduct.stock,
        qtyToAdd: qty,
        addons: addons,
        addonStocks: addonStocks,
      );

      if (!validation.isValid) {
        emit(state.copyWith(errorMessage: validation.message));
        return;
      }

      final newLine = CartLine(
        productId: latestProduct.id,
        productName: latestProduct.name,
        unitPrice: latestProduct.price,
        qty: qty,
        addons: addons,
      );

      final existingIndex = state.items.indexWhere(
        (line) => line.hasSameIdentity(newLine),
      );

      final List<CartLine> updatedItems;
      if (existingIndex != -1) {
        final existingLine = state.items[existingIndex];
        final updatedLine = existingLine.copyWith(qty: existingLine.qty + qty);
        updatedItems = List<CartLine>.from(state.items)..[existingIndex] = updatedLine;
      } else {
        updatedItems = [...state.items, newLine];
      }

      final subtotal =
          updatedItems.fold<int>(0, (sum, line) => sum + line.lineTotal);
      final newDiscount = _reconcileDiscount(state.discount, subtotal);
      final newTotals = _computeTotals(updatedItems, newDiscount);

      emit(state.copyWith(
        items: updatedItems,
        discount: newDiscount,
        totals: newTotals,
        clearError: true,
      ));
    } catch (_) {
      emit(state.copyWith(
        errorMessage: 'Gagal memuat data stok terbaru.',
      ));
    }
  }

  /// Convenience helper to add a product with [Addon] domain entities.
  Future<void> addProductWithAddons(
    Product product,
    List<Addon> addons, {
    int qty = 1,
  }) {
    return addProduct(
      product,
      addons: addons.map(CartAddon.fromAddon).toList(),
      qty: qty,
    );
  }

  /// Updates quantity of an existing [CartLine].
  /// Downward adjustment is always permitted; upward adjustment checks current stock.
  Future<void> updateQuantity(CartLine targetLine, int newQty) async {
    final index = state.items.indexWhere(
      (item) => item.hasSameIdentity(targetLine),
    );
    if (index == -1) return;

    if (newQty <= 0) {
      removeLine(targetLine);
      return;
    }

    final currentLine = state.items[index];
    if (newQty == currentLine.qty) return;

    if (newQty < currentLine.qty) {
      final updatedLine = currentLine.copyWith(qty: newQty);
      final updatedItems = List<CartLine>.from(state.items)..[index] = updatedLine;
      final subtotal =
          updatedItems.fold<int>(0, (sum, line) => sum + line.lineTotal);
      final newDiscount = _reconcileDiscount(state.discount, subtotal);
      final newTotals = _computeTotals(updatedItems, newDiscount);

      emit(state.copyWith(
        items: updatedItems,
        discount: newDiscount,
        totals: newTotals,
        clearError: true,
      ));
      return;
    }

    try {
      final latestProduct = await getProductById(currentLine.productId);
      if (latestProduct == null || latestProduct.isDeleted) {
        emit(state.copyWith(
          errorMessage:
              'Produk ${currentLine.productName} tidak ditemukan atau sudah tidak aktif.',
        ));
        return;
      }

      final addonStocks = <int, int>{};
      for (final addon in currentLine.addons) {
        if (!addonStocks.containsKey(addon.id)) {
          final latestAddon = await getAddonById(addon.id);
          if (latestAddon == null || latestAddon.isDeleted) {
            emit(state.copyWith(
              errorMessage:
                  'Add-on ${addon.name} tidak ditemukan atau sudah tidak aktif.',
            ));
            return;
          }
          addonStocks[addon.id] = latestAddon.stock;
        }
      }

      final validation = stockValidator.validateUpdateQty(
        currentCart: state.items,
        targetLine: currentLine,
        newQty: newQty,
        availableProductStock: latestProduct.stock,
        addonStocks: addonStocks,
      );

      if (!validation.isValid) {
        emit(state.copyWith(errorMessage: validation.message));
        return;
      }

      final updatedLine = currentLine.copyWith(qty: newQty);
      final updatedItems = List<CartLine>.from(state.items)..[index] = updatedLine;
      final subtotal =
          updatedItems.fold<int>(0, (sum, line) => sum + line.lineTotal);
      final newDiscount = _reconcileDiscount(state.discount, subtotal);
      final newTotals = _computeTotals(updatedItems, newDiscount);

      emit(state.copyWith(
        items: updatedItems,
        discount: newDiscount,
        totals: newTotals,
        clearError: true,
      ));
    } catch (_) {
      emit(state.copyWith(
        errorMessage: 'Gagal memuat data stok terbaru.',
      ));
    }
  }

  /// Alias for [updateQuantity].
  Future<void> updateQty(CartLine targetLine, int newQty) =>
      updateQuantity(targetLine, newQty);

  /// Removes a line from the cart.
  void removeLine(CartLine targetLine) {
    final updatedItems = state.items
        .where((item) => !item.hasSameIdentity(targetLine))
        .toList();

    if (updatedItems.length == state.items.length) {
      return;
    }

    if (updatedItems.isEmpty) {
      emit(const CartState());
      return;
    }

    final subtotal =
        updatedItems.fold<int>(0, (sum, line) => sum + line.lineTotal);
    final newDiscount = _reconcileDiscount(state.discount, subtotal);
    final newTotals = _computeTotals(updatedItems, newDiscount);

    emit(state.copyWith(
      items: updatedItems,
      discount: newDiscount,
      totals: newTotals,
      clearError: true,
    ));
  }

  /// Sets or updates the discount on the cart.
  void setDiscount(Discount discount) {
    final validation =
        discountCalculator.validate(discount, state.totals.subtotal);
    if (!validation.isValid) {
      emit(state.copyWith(errorMessage: validation.message));
      return;
    }

    final newTotals = _computeTotals(state.items, discount);
    emit(state.copyWith(
      discount: discount,
      totals: newTotals,
      clearError: true,
    ));
  }

  /// Clears all cart items, discounts, and errors.
  void clearCart() {
    emit(const CartState());
  }

  /// Clears any current error message from the state.
  void clearError() {
    if (state.errorMessage != null) {
      emit(state.copyWith(clearError: true));
    }
  }

  CartTotals _computeTotals(List<CartLine> items, Discount discount) {
    if (items.isEmpty) {
      return const CartTotals.zero();
    }
    return CartTotals.compute(
      lines: items,
      discount: discount,
      calculator: discountCalculator,
    );
  }

  Discount _reconcileDiscount(Discount discount, int subtotal) {
    if (subtotal <= 0) {
      return const Discount.none();
    }
    final validation = discountCalculator.validate(discount, subtotal);
    if (!validation.isValid) {
      return const Discount.none();
    }
    return discount;
  }
}
