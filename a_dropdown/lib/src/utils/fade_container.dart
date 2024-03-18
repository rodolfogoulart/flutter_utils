import 'package:flutter/widgets.dart';

class FadeContainer extends StatefulWidget {
  const FadeContainer({super.key, required this.child, required this.duration});

  final Widget child;
  final Duration duration;
  
  @override
  State<FadeContainer> createState() => _FadeContainerState();
}

class _FadeContainerState extends State<FadeContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
  }

  

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward();
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
