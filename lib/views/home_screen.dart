import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/viewmodels/auth_viewmodel.dart';
import 'package:app/models/pomodoro_timer.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final PomodoroTimer _timer = PomodoroTimer();
  bool _isRunning = false;
  late Timer _countdownTimer;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _timer.start();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _timer.remainingTime),
    );
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startStopTimer() {
    setState(() {
      if (_isRunning) {
        _countdownTimer.cancel();
        _animationController.stop();
      } else {
        _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          setState(() {
            _timer.tick();
            _animationController.duration = Duration(seconds: _timer.remainingTime);
          });
        });
        _animationController.forward(from: 0.0);
      }
      _isRunning = !_isRunning;
    });
  }

  void _logout() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    await authViewModel.signOut();
    
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const LoginScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final String timeRemaining = _formatTime(_timer.remainingTime);
    final String status = _timer.status;

    return Scaffold(
      backgroundColor: _timer.status == "Trabajo" ? Colors.blue[800] : Colors.green[700],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Tarjeta del Temporizador con animación circular
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.white.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        status,
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TweenAnimationBuilder(
                        tween: Tween(begin: 1.0, end: _animationController.value),
                        duration: Duration(seconds: 1),
                        builder: (context, double value, _) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 180,
                                width: 180,
                                child: CircularProgressIndicator(
                                  value: 1 - value,
                                  strokeWidth: 8,
                                  color: _timer.status == "Trabajo" ? Colors.blue : Colors.green,
                                ),
                              ),
                              Text(
                                timeRemaining,
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Botón para iniciar o detener el temporizador
              ElevatedButton.icon(
                onPressed: _startStopTimer,
                icon: Icon(
                  _isRunning ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                label: Text(
                  _isRunning ? 'Detener' : 'Iniciar',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _logout,
        backgroundColor: Colors.red,
        child: const Icon(Icons.exit_to_app, color: Colors.white),
      ),
    );
  }
}
