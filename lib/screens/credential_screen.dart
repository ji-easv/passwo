import 'package:flutter/material.dart';

import '../models/credential.dart';

class CredentialScreen extends StatefulWidget {
  final Credential? existingCredential;

  const CredentialScreen({super.key, this.existingCredential});

  @override
  State<CredentialScreen> createState() => _CredentialScreenState();
}

class _CredentialScreenState extends State<CredentialScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
