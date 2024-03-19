import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:logging_appenders/logging_appenders.dart';
import 'package:password_manager/core/logger_bloc_observer.dart';
import 'package:password_manager/core/vault_api.dart';
import 'package:password_manager/core/vault_cubit.dart';
import 'package:password_manager/infrastructure/protection.dart';

import 'core/vault_state.dart';
import 'infrastructure/storage.dart';
import 'screens/password_screen.dart';

void main() async {
  PrintAppender(
    formatter: const ColorFormatter(),
  ).attachToLogger(Logger.root);
  Bloc.observer = LoggerBlocObserver();

  WidgetsFlutterBinding.ensureInitialized();
  final storage = await Storage.create();

  runApp(BlocProvider(
    create: (context) => VaultCubit(
      VaultApi(
        protector: Protection.sensibleDefaults(),
        storage: storage,
      ),
    ),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Manager',
      home: BlocListener<VaultCubit, VaultState>(
        listenWhen: (previous, current) => current.failure != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.failure!.message,
              ),
            ),
          );
        },
        child: const PasswordScreen(),
      ),
    );
  }
}
