import '../../../../core/error/result.dart';
import '../entities/checkout_params.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  /// Executes atomic checkout with stock validation, invoice generation,
  /// transaction snapshot insertion, and stock deduction inside a single database transaction.
  Future<Result<Transaction>> checkout(CheckoutParams params);

  /// Retrieves a transaction by its primary key ID, including snapshots of items and add-ons.
  Future<Transaction?> getTransactionById(int id);

  /// Retrieves a transaction by its unique invoice number.
  Future<Transaction?> getTransactionByInvoiceNo(String invoiceNo);

  /// Retrieves all transaction history snapshots.
  Future<List<Transaction>> getTransactions();

  /// Broadcast stream notifying whenever a new transaction is committed to the database.
  Stream<Transaction> get onTransactionCommitted => const Stream.empty();
}

