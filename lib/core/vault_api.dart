import 'package:password_manager/infrastructure/protection.dart';
import 'package:password_manager/models/credential.dart';
import 'package:password_manager/models/open_vault.dart';

import '../infrastructure/storage.dart';
import 'failures.dart';

class VaultApi {
  final Storage _storage;
  final Protection _protector;

  VaultApi({required storage, required Protection protector})
      : _protector = protector,
        _storage = storage;

  bool get exists => _storage.exits;

/*
Creates a vault that can only be opened with the given master-password.
 */
  Future<OpenVault> create(String masterPassword) async {
    final key = await _protector.createKey(masterPassword);
    final vault = OpenVault(credentials: <Credential>[], key: key);
    await _storage.save(await _protector.encrypt(vault));
    return vault;
  }

  Future<OpenVault> open(String masterPassword) async {
    final vault = _storage.load();
    if (vault == null) throw VaultNotFoundFailure();
    final key = await _protector.recreateKey(vault, masterPassword);
    final credentials = await _protector.decrypt(vault, key);
    return OpenVault(credentials: credentials, key: key);
  }

  Future<bool> save(OpenVault openVault) async {
    final encryptedVault = await _protector.encrypt(openVault);
    return await _storage.save(encryptedVault);
  }
}
