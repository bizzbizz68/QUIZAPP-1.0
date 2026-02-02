import 'dart:async';
import 'package:flutter/material.dart';

/// Timer Widget
/// Countdown timer cho exam
class TimerWidget extends StatefulWidget {
  final DateTime startTime;
  final int durationMinutes;
  final VoidCallback onTimeUp;

  const TimerWidget({
    Key? key,
    required this.startTime,
    required this.durationMinutes,
    required this.onTimeUp,
  }) : super(key: key);

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _hasCalledTimeUp = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _calculateRemaining();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _calculateRemaining();
        
        if (_remainingSeconds <= 0 && !_hasCalledTimeUp) {
          _hasCalledTimeUp = true;
          widget.onTimeUp();
        }
      });
    });
  }

  void _calculateRemaining() {
    final elapsed = DateTime.now().difference(widget.startTime);
    final allowedSeconds = widget.durationMinutes * 60;
    _remainingSeconds = (allowedSeconds - elapsed.inSeconds).clamp(0, allowedSeconds);
  }

  String _formatTime() {
    final hours = _remainingSeconds ~/ 3600;
    final minutes = (_remainingSeconds % 3600) ~/ 60;
    final seconds = _remainingSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color _getTimerColor() {
    if (_remainingSeconds <= 300) {
      // Last 5 minutes: red
      return Colors.red;
    } else if (_remainingSeconds <= 600) {
      // Last 10 minutes: orange
      return Colors.orange;
    }
    return Colors.white;
  }

  IconData _getTimerIcon() {
    if (_remainingSeconds <= 300) {
      return Icons.timer_off;
    }
    return Icons.timer;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: _getTimerColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getTimerColor(),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getTimerIcon(),
            color: _getTimerColor(),
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            _formatTime(),
            style: TextStyle(
              color: _getTimerColor(),
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
