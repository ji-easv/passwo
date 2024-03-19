import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/credential.dart';
import 'credential_screen.dart';

class CredentialList extends StatelessWidget {
  final IList<Credential> credentials;

  const CredentialList({
    super.key,
    required this.credentials,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemBuilder: (context, index) =>
            CredentialListTile(credential: credentials[index]),
        separatorBuilder: (context, index) => const Divider(),
        itemCount: credentials.length);
  }
}

class CredentialListTile extends StatelessWidget {
  final Credential credential;
  const CredentialListTile({
    super.key,
    required this.credential,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(credential.name),
      subtitle: Text(credential.username),
      trailing: PopupMenuButton<MenuAction>(
        onSelected: (MenuAction action) => action.call(),
        itemBuilder: (context) => <PopupMenuEntry<MenuAction>>[
          PopupMenuItem<MenuAction>(
            value: () => Clipboard.setData(
              ClipboardData(text: credential.username),
            ),
            child: const Text('Copy username'),
          ),
          PopupMenuItem<MenuAction>(
            value: () => Clipboard.setData(
              ClipboardData(text: credential.password),
            ),
            child: const Text('Copy password'),
          ),
          PopupMenuItem<MenuAction>(
            value: () {
              // TODO: remove credential
            },
            child: const Text('Remove'),
          ),
        ],
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              CredentialScreen(existingCredential: credential),
        ),
      ),
    );
  }
}

typedef MenuAction = void Function();
