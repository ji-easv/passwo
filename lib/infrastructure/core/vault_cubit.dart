import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:password_manager/infrastructure/core/failures.dart';
import 'package:password_manager/infrastructure/core/vault_api.dart';
import 'package:password_manager/infrastructure/core/vault_state.dart';
import 'package:password_manager/models/credential.dart';
import 'package:password_manager/models/open_vault.dart';

import '../protection.dart';

/*
A Cubit would normally not have any instance variables (other than through its constructor). 
Doing it here is a compromise, as I don't want the key anyway near UI. 
 */
class VaultCubit extends Cubit<VaultState> {
  static const closeAfter = Duration(minutes: 1);
  Timer? _timer;

  final VaultApi api;
  Key? _key;

  VaultCubit(this.api) : super(VaultState.initial(api.exists));

  @override
  void onChange(Change<VaultState> change) {
    super.onChange(change);
    if (change.nextState.status == VaultStatus.open) {
      _timer?.cancel();
      _timer = Timer(closeAfter, closeVault);
    }
  }

  Future<void> createVault(String masterPassword) async {
    // If a valut is absent, create a new one
    // We shouldn't allow accidentally overwting all stored passwords
    assert(state.status == VaultStatus.absent);

    // Start by emitting an 'opening' state, so the UI can show a loading spinner
    emit(state.ok(status: VaultStatus.opening));

    try {
      // Ask api to create a new vault which can be opened with the given master-password
      final vault = await api.create(masterPassword);
      // the key shouldn't be accesible through the UI so it's stored in  private instance variable
      _key = vault.key;

      // Emit 'open' state with credentials converted to immutable list
      emit(
        state.ok(
          credentials: vault.credentials.lock,
          status: VaultStatus.open,
        ),
      );
    } catch (e) {
      // If something goes wrong, emit a new 'absent' state with a generic failure
      emit(
        state.failed(
          reason: UnknownFailure(),
          status: VaultStatus.absent,
        ),
      );

      // Forward details to 'addError' so a BlocObserver can log the error
      addError(e);
    }
  }

  Future<void> openVault(String masterPassword) async {
    // It doesn't make sense to open a vault if it's absent
    assert(state.status == VaultStatus.closed);

    // Emit 'opening' state so the UI can show a loading spinner
    emit(state.ok(status: VaultStatus.opening));
    try {
      // Attempt to open the vault with the given master-password.
      // This will throw an exception if the password is incorrect.
      final vault = await api.open(masterPassword);

      // The key shouldn't be accesible through the UI so it's stored in  private instance variable
      _key = vault.key;

      // Emit 'open' state with credentials converted to immutable list
      emit(
        state.ok(
          credentials: vault.credentials.lock,
          status: VaultStatus.open,
        ),
      );
    } catch (e) {
      // If something goes wrong, emit a new 'absent' state with a specific failure
      emit(
        state.failed(
          status: VaultStatus.closed,
          reason: OpenVaultFailure(),
        ),
      );

      // Forward details to 'addError' so a BlocObserver can log the error
      addError(e);
    }
  }

  Future<void> addCredential(Credential credential) async {
    // Vault must be open to add a credential
    assert(state.status == VaultStatus.open);

    // Emit 'saving' state so the UI can show a loading spinner
    emit(state.ok(status: VaultStatus.saving));

    try {
      // 'unlock' (get a mutable copy of) credentials, then add a new credential
      final credentials = state.credentials.unlock..add(credential);

      // Save the new credentials immediately
      await api.save(OpenVault(credentials: credentials, key: _key!));

      // 'lock' (get immutable copy of) credentials and emit 'open' state
      emit(
        state.ok(
          credentials: credentials.lock,
          status: VaultStatus.open,
        ),
      );
    } catch (e) {
      // Transition back to 'open' state if something goes wrong
      emit(
        state.failed(
          status: VaultStatus.open,
          reason: SaveVaultFailure(),
        ),
      );
      addError(e);
    }
  }

  void closeVault() {
    // Destroy the key, so the user has to open it with the same master-password to access the credentials again
    _key?.destroy();

    // Emit 'closed' state with empty credentials
    emit(
      state.ok(
        credentials: <Credential>[].lock,
        status: VaultStatus.closed,
      ),
    );
  }
}
