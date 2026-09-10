import 'dart:async';

import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  const CountdownTimer({
    super.key,
    required this.endTime,
    this.compact = false,
  });

  final DateTime endTime;
  final bool compact;

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateRemaining(),
    );
  }

  void _updateRemaining() {
    final remaining = widget.endTime.difference(DateTime.now());
    if (!mounted) return;
    setState(
      () => _remaining = remaining.isNegative ? Duration.zero : remaining,
    );
  }

  String _format(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return duration.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.schedule_rounded,
          size: widget.compact ? 16 : 20,
          color: widget.compact ? Colors.white : Colors.orange.shade800,
        ),
        const SizedBox(width: 5),
        Text(
          widget.compact ? _format(_remaining) : 'Sisa ${_format(_remaining)}',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: widget.compact ? Colors.white : Colors.orange.shade900,
            fontSize: widget.compact ? 13 : 16,
          ),
        ),
      ],
    );
  }
}
