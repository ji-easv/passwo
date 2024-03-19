abstract class Failure implements Exception {
  String get message;
}

class OpenVaultFailure extends Failure {
  @override
  String get message =>
      'Failed to open vault. Are you sure the password is correct?';
}

class VaultNotFoundFailure extends Failure {
  @override
  String get message => 'Vault not found.';
}

class SaveVaultFailure extends Failure {
  @override
  String get message => 'Failed to save vault. Please try again or check logs.';
}

class UnknownFailure extends Failure {
  @override
  String get message =>
      'An unknown error occurred. Please try again or see logs for details.';
}
