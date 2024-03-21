import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:password_manager/core/vault_cubit.dart';

import '../core/vault_state.dart';
import 'password_form.dart';
import 'vault_screen.dart';

class PasswordScreen extends StatelessWidget {
  const PasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter your master password'),
        centerTitle: true,
      ),
      body: BlocConsumer<VaultCubit, VaultState>(
        listenWhen: (previous, current) => current.status == VaultStatus.open,
        listener: (context, state) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const VaultScreen(),
            ),
          );
        },
        builder: (context, state) {
          return switch (state.status) {
            VaultStatus.absent => PasswordForm(
                onSubmit: (password) =>
                    context.read<VaultCubit>().createVault(password),
                buttonText: "Create",
              ),
            VaultStatus.closed => PasswordForm(
                onSubmit: (password) =>
                    context.read<VaultCubit>().openVault(password),
                buttonText: "Open",
              ),
            _ => const Center(child: CircularProgressIndicator()),
          };
        },
      ),
    );
  }
}
