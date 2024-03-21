import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:password_manager/core/vault_cubit.dart';
import 'package:password_manager/core/vault_state.dart';

import '../models/credential.dart';

class CredentialScreen extends StatefulWidget {
  final Credential? existingCredential;

  const CredentialScreen({super.key, this.existingCredential});

  @override
  State<CredentialScreen> createState() => _CredentialScreenState();
}

class _CredentialScreenState extends State<CredentialScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  var showPassword = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.existingCredential?.name);
    _usernameController =
        TextEditingController(text: widget.existingCredential?.username);
    _passwordController =
        TextEditingController(text: widget.existingCredential?.password);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void save() {
    final vault = context.read<VaultCubit>();
    final credential = Credential(
        name: _nameController.text,
        username: _usernameController.text,
        password: _passwordController.text);
    if (widget.existingCredential == null) {
      vault.addCredential(credential);
    } else {
      // TODO: update credential
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credential'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            NameField(controller: _nameController),
            UsernameField(controller: _usernameController),
            PasswordField(controller: _passwordController),
            const SizedBox(
              height: 16,
            ),
            SaveButton(onSave: save),
          ],
        ),
      ),
    );
  }
}

class NameField extends StatelessWidget {
  final TextEditingController controller;

  const NameField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(labelText: 'Name/Site'),
    );
  }
}

class UsernameField extends StatelessWidget {
  final TextEditingController controller;

  const UsernameField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(labelText: 'Usernames'),
    );
  }
}

class PasswordField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordField({super.key, required this.controller});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: TextFormField(
            controller: widget.controller,
            obscureText: !showPassword,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.outlined(
          onPressed: () {
            setState(() => showPassword = !showPassword);
          },
          icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off),
        ),
        const SizedBox(width: 8),
        IconButton.outlined(
          onPressed: () {
            // TODO: generate password
          },
          icon: const Icon(Icons.casino),
        ),
      ],
    );
  }
}

class SaveButton extends StatelessWidget {
  final Function() onSave;

  const SaveButton({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VaultCubit, VaultState>(builder: (context, state) {
      if (state.status == VaultStatus.saving) {
        return const CircularProgressIndicator();
      } else {
        return ElevatedButton(
          onPressed: onSave,
          child: const Text('Save'),
        );
      }
    });
  }
}
