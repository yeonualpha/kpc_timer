import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TimerStatus { running, puased, stopped, resting }

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  static const WORK_TIME = 10;
  static const REST_TIME = 5;

  late SharedPreferences prefs;

  late int _timer;
  late int _pomodoroCount;
  late TimerStatus _timerStatus;

  String formatDatetime(int second) {
    DateTime dt = DateTime(0, 0, 0, 0, 0, second);
    return '${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  Future<void> loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
    _pomodoroCount = prefs.getInt('pomodoroCount') ?? 0;
  }

  @override
  void initState() {
    super.initState();
    loadPrefs();
    _timer = WORK_TIME;
    _timerStatus = TimerStatus.stopped;
  }

  /// RUN
  void run() {
    setState(() {
      _timerStatus = TimerStatus.running;
    });
    runTimer();
  }

  /// REST
  void rest() {
    setState(() {
      _timer = REST_TIME;
      _timerStatus = TimerStatus.resting;
    });
  }

  /// PAUSE
  void pause() {
    setState(() {
      _timerStatus = TimerStatus.puased;
    });
  }

  /// RESUME
  void resume() {
    run();
  }

  /// STOP
  void stop() {
    setState(() {
      _timer = WORK_TIME;
      _timerStatus = TimerStatus.stopped;
    });
    // print('Stop: $_timerStatus/$_timer');
  }

  /// Count the time down.
  void runTimer() async {
    Timer.periodic(const Duration(seconds: 1), (t) {
      // print('runTime A: $_timerStatus/$_timer');
      switch (_timerStatus) {
        case TimerStatus.puased:
          t.cancel();
          break;
        case TimerStatus.stopped:
          t.cancel();
          break;
        case TimerStatus.running:
          if (_timer <= 0) {
            rest();
          } else {
            setState(() {
              _timer -= 1;
            });
          }
          break;
        case TimerStatus.resting:
          if (_timer <= 0) {
            setState(() {
              _pomodoroCount += 1;
              prefs.setInt('pomodoroCount', _pomodoroCount);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$_pomodoroCount 뽀모도로 달성!')),
              );
            });
            t.cancel();
            stop();
          } else {
            setState(() {
              _timer -= 1;
            });
          }
          break;
        default:
          break;
      }
      // print('runTime B: $_timerStatus/$_timer');
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> runningButtons = [
      ElevatedButton(
          onPressed: _timerStatus == TimerStatus.puased ? resume : pause,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: Text(
            _timerStatus == TimerStatus.puased ? 'RESUME' : 'PAUSE',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          )),
      const Padding(padding: EdgeInsets.all(20)),
      ElevatedButton(
          onPressed: stop,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          child: const Text(
            'STOP',
            style: TextStyle(color: Colors.black, fontSize: 16),
          ))
    ];
    List<Widget> stoppedButtons = [
      ElevatedButton(
          onPressed: run,
          style: ElevatedButton.styleFrom(
              backgroundColor: _timerStatus == TimerStatus.resting
                  ? Colors.green
                  : Colors.blue),
          child: const Text(
            'RUN',
            style: TextStyle(color: Colors.white, fontSize: 16),
          )),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('KPC Timer'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
                color: _timerStatus == TimerStatus.resting
                    ? Colors.green
                    : Colors.blue,
                shape: BoxShape.circle),
            child: Center(
              child: Text(
                formatDatetime(_timer),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _timerStatus == TimerStatus.resting
                ? const []
                : _timerStatus == TimerStatus.stopped
                    ? stoppedButtons
                    : runningButtons,
          ),
        ],
      ),
    );
  }
}
