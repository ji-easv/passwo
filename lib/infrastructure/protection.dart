import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:password_manager/models/credential.dart';
import 'package:password_manager/models/encrypted_vault.dart';

import '../models/open_vault.dart';

/*
Sealed classes are abstract classes that cannot be extended outside their own package. See sealed class modifier.
It means that the only way to instantiate Key is through its _Key sub-class which isn’t accessible outside its own package. The only publicly available part of Key is its destroy() method. The application should call destroy when the key is no longer needed. In other words when we are closing the vault. */

sealed class Key {
  void destroy();
}

class _Key extends Key {
  final SecretKey secretKey;
  final List<int> salt;

  _Key(this.secretKey, {required this.salt});

  @override
  void destroy() {
    secretKey.destroy();
    salt.setAll(0, List.filled(salt.length, 0));
  }
}

extension EncryptedValutX on EncryptedVault {
  SecretBox toSecretBox() => SecretBox(ciphertext, nonce: nonce, mac: Mac(mac));
}

extension SecretBoxX on SecretBox {
  EncryptedVault toEncryptedVault({required List<int> salt}) {
    return EncryptedVault(
      salt: salt,
      nonce: nonce,
      mac: mac.bytes,
      ciphertext: cipherText,
    );
  }
}

class Protection {
  final KdfAlgorithm kdfAlgorithm;
  final Cipher cipher;

  Protection({required this.kdfAlgorithm, required this.cipher});

  Protection.sensibleDefaults()
      : kdfAlgorithm = Argon2id(
          parallelism: 1,
          memory: 12288,
          iterations: 3,
          hashLength: 256 ~/ 8,
        ),
        cipher = AesGcm.with256bits();

  Future<Key> createKey(String masterPassword) async {
    final salt = generateSalt();
    final secretKey = await kdfAlgorithm.deriveKeyFromPassword(
        password: masterPassword, nonce: salt);
    return _Key(secretKey, salt: salt);
  }

  List<int> generateSalt() =>
      List<int>.generate(32, (i) => SecureRandom.safe.nextInt(256));

  Future<Key> recreateKey(EncryptedVault vault, String masterPassword) async {
    final secretKey = await kdfAlgorithm.deriveKeyFromPassword(
        password: masterPassword, nonce: vault.salt);
    return _Key(secretKey, salt: vault.salt);
  }

  Future<List<Credential>> decrypt(
      EncryptedVault encryptedVault, Key key) async {
    final jsonString = await cipher.decryptString(encryptedVault.toSecretBox(),
        secretKey: (key as _Key).secretKey);
    final json = jsonDecode(jsonString) as List<dynamic>;
    return List<Credential>.from(json.map((e) => Credential.fromJson(e)));
  }

  Future<EncryptedVault> encrypt(OpenVault openVault) async {
    final key = (openVault.key as _Key);
    final encrypted = await cipher.encryptString(
        jsonEncode(openVault.credentials),
        secretKey: key.secretKey);
    return encrypted.toEncryptedVault(salt: key.salt);      
  }
}