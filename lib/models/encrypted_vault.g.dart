// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encrypted_vault.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EncryptedVault _$EncryptedVaultFromJson(Map<String, dynamic> json) =>
    EncryptedVault(
      salt: const Base64Converter().fromJson(json['salt'] as String),
      nonce: const Base64Converter().fromJson(json['nonce'] as String),
      mac: const Base64Converter().fromJson(json['mac'] as String),
      ciphertext:
          const Base64Converter().fromJson(json['ciphertext'] as String),
    );

Map<String, dynamic> _$EncryptedVaultToJson(EncryptedVault instance) =>
    <String, dynamic>{
      'salt': const Base64Converter().toJson(instance.salt),
      'nonce': const Base64Converter().toJson(instance.nonce),
      'mac': const Base64Converter().toJson(instance.mac),
      'ciphertext': const Base64Converter().toJson(instance.ciphertext),
    };
