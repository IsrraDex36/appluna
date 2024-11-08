import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';

class PomodoroTimer {
  final int workDuration = 1;  // Duración de trabajo en minutos
  final int breakDuration = 5;  // Duración de descanso en minutos
  late int _remainingTime;  // Tiempo restante en segundos
  bool _isWorking = true;  // Indica si el temporizador está en modo trabajo o descanso
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Inicia el temporizador
  void start() {
    _remainingTime = _isWorking ? workDuration * 60 : breakDuration * 60;
  }

  // Actualiza el tiempo restante
  String tick() {
    if (_remainingTime > 0) {
      _remainingTime--;
    } else {
      _isWorking = !_isWorking;  // Cambiar entre trabajo y descanso
      start();
      _onTimerEnd();  // Llamar a la función que maneja el evento de fin de temporizador
    }
    return formatTime(_remainingTime);
  }

  // Función que maneja lo que pasa cuando el temporizador llega a cero
  void _onTimerEnd() async {
    // Verificar si el dispositivo admite vibración y vibrar
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate();
    }

    // Mostrar notificación
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'pomodoro_channel_id', 
      'Pomodoro Timer', 
      channelDescription: 'Notificaciones del temporizador Pomodoro',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,  // ID de la notificación
      _isWorking ? '¡Tiempo de descanso!' : '¡Vuelve a trabajar!',
      'El temporizador ha terminado.',
      notificationDetails,
    );
  }

  // Formatea el tiempo en minutos:segundos
  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int sec = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  // Detiene el temporizador
  void stop() {
    _remainingTime = 0;
  }

  // Obtiene el estado actual del temporizador (trabajo o descanso)
  String get status => _isWorking ? "Trabajo" : "Descanso";

  // Getter para obtener el tiempo restante
  int get remainingTime => _remainingTime;
}
