// main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/views/login_screen.dart';
import 'package:app/views/home_screen.dart';
import 'package:app/viewmodels/auth_viewmodel.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Esto se usa en las notificaciones
import 'firebase_options.dart';

// Configuración de las notificaciones
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


void main() async {
  // Asegúrate de que Firebase se inicialice antes de que se ejecute cualquier cosa
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializa las notificaciones
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: MaterialApp(
        title: 'Pomodoro App',
        theme: ThemeData(primarySwatch: Colors.blue),
        darkTheme: ThemeData(brightness: Brightness.dark, primarySwatch: Colors.blue),
        themeMode: ThemeMode.system, // Detecta y ajusta el modo oscuro según la configuración del sistema
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Observa el estado de autenticación
    return StreamBuilder<User?>(
      stream: Provider.of<AuthViewModel>(context).authStream,
      builder: (context, snapshot) {
        // Si estamos esperando a que Firebase entregue la info
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Si el usuario está autenticado, navega a la pantalla principal
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // Si no está autenticado, redirige a la pantalla de login
        return const LoginScreen();
      },
    );
  }
}
