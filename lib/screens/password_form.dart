import 'package:flutter/material.dart';

class PasswordForm extends StatefulWidget {
  final Function(String) onSubmit;
  final String buttonText;

  const PasswordForm({
    super.key,
    required this.onSubmit,
    required this.buttonText,
  });

  @override
  State<PasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends State<PasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(_passwordController.text);
    }
  }

  String? _passwordValidator(String? value) {
    const minLength = 8;
    final invalid = value == null || value.length < minLength;
    return invalid ? 'Password must be at least $minLength characters' : null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _passwordController,
              validator: _passwordValidator,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              onChanged: (newValue) => _formKey.currentState!.validate(),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _handleSubmit,
                child: Text(widget.buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
