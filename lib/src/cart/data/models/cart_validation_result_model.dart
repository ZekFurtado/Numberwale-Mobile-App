import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/cart/data/models/cart_model.dart';
import 'package:numberwale/src/cart/domain/entities/cart_validation_result.dart';

class CartValidationResultModel extends CartValidationResult {
  const CartValidationResultModel({
    required super.itemResults,
    required super.cart,
  });

  /// [map] is the `data` object of the POST /cart/validate response:
  /// `{ validationResults: [{productId, valid, message}], cart: {...} }`.
  factory CartValidationResultModel.fromMap(DataMap map) {
    final rawResults = map['validationResults'] as List<dynamic>? ?? const [];
    final itemResults = rawResults.map((r) {
      final item = r as DataMap;
      return CartItemValidation(
        productId: item['productId'] as String? ?? '',
        valid: item['valid'] as bool? ?? true,
        message: item['message'] as String? ?? '',
      );
    }).toList();

    return CartValidationResultModel(
      itemResults: itemResults,
      cart: CartModel.fromMap(map),
    );
  }
}
