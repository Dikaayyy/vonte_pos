import '../../../../core/error/exceptions.dart';
import '../entities/store_profile.dart';
import '../repositories/store_profile_repository.dart';
import '../validators/store_profile_validator.dart';

class UpdateStoreProfile {
  final StoreProfileRepository _repository;

  const UpdateStoreProfile(this._repository);

  Future<StoreProfile> call(StoreProfile profile) async {
    final nameError = StoreProfileValidator.validateName(profile.name);
    if (nameError != null) throw ValidationException(nameError);

    final addressError = StoreProfileValidator.validateAddress(profile.address);
    if (addressError != null) throw ValidationException(addressError);

    final phoneError = StoreProfileValidator.validatePhone(profile.phone);
    if (phoneError != null) throw ValidationException(phoneError);

    final footerError =
        StoreProfileValidator.validateReceiptFooter(profile.receiptFooter);
    if (footerError != null) throw ValidationException(footerError);

    final normalized = profile.copyWith(
      name: profile.name.trim(),
      address: profile.address.trim(),
      phone: profile.phone.trim(),
      receiptFooter: profile.receiptFooter.trim(),
    );

    return _repository.updateStoreProfile(normalized);
  }
}

