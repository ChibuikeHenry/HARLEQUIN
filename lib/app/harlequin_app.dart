import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_strings.dart';
import '../data/repositories/app_repository.dart';
import '../viewmodels/session_viewmodel.dart';
import 'router.dart';
import 'theme.dart';

class HarlequinApp extends StatefulWidget {
  const HarlequinApp({super.key});

  @override
  State<HarlequinApp> createState() => _HarlequinAppState();
}

class _HarlequinAppState extends State<HarlequinApp> {
  late final AuthRepository _authRepository;
  late final AppRepository _appRepository;
  late final SessionViewModel _session;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository();
    _appRepository = AppRepository();
    _session = SessionViewModel(_authRepository);
    _router = createRouter(_session);
    unawaited(_session.init());
  }

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: _authRepository),
        Provider<AppRepository>.value(value: _appRepository),
        ChangeNotifierProvider<SessionViewModel>.value(value: _session),
      ],
      child: MaterialApp.router(
        title: AppStrings.brand,
        debugShowCheckedModeBanner: false,
        theme: HarlequinTheme.light,
        routerConfig: _router,
      ),
    );
  }
}
