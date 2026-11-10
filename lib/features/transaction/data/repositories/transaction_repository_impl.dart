import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/checkout_params.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/services/invoice_number_generator.dart';
import '../datasources/transaction_local_data_source.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource _localDataSource;
  final InvoiceNumberGenerator _invoiceGenerator;

  TransactionRepositoryImpl(
    this._localDataSource,
    this._invoiceGenerator,
  );

  @override
  Future<Result<Transaction>> checkout(CheckoutParams params) async {
    try {
      final model = await _localDataSource.executeCheckout(
        params: params,
        invoiceGenerator: _invoiceGenerator,
      );
      return Result.success(model.toEntity());
    } on AppException catch (e) {
      return Result.failure(CheckoutFailure(e.message));
    } catch (e) {
      return Result.failure(CheckoutFailure(e.toString()));
    }
  }

  @override
  Future<Transaction?> getTransactionById(int id) async {
    final model = await _localDataSource.getTransactionById(id);
    return model?.toEntity();
  }

  @override
  Future<Transaction?> getTransactionByInvoiceNo(String invoiceNo) async {
    final model = await _localDataSource.getTransactionByInvoiceNo(invoiceNo);
    return model?.toEntity();
  }

  @override
  Future<List<Transaction>> getTransactions() async {
    final models = await _localDataSource.getTransactions();
    return models.map((m) => m.toEntity()).toList();
  }
}

