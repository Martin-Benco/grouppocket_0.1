import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_state.dart';

class AnimatedAmountInput extends StatefulWidget {
  const AnimatedAmountInput({super.key});

  @override
  State<AnimatedAmountInput> createState() => _AnimatedAmountInputState();
}

class _AnimatedAmountInputState extends State<AnimatedAmountInput>
    with TickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _animationController;
  bool _isAnimating = false;
  bool _isFilled = false;
  
  final List<String> _sampleAmounts = ['30', '60', '120', '12.50'];
  int _currentSampleIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '€');
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 160),
      vsync: this,
    );
    
    // Start animation after a delay
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _startTypingAnimation();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  void _startTypingAnimation() {
    if (_isAnimating || _isFilled) return;
    
    _isAnimating = true;
    final sampleText = _sampleAmounts[_currentSampleIndex];
    
    _typeText(sampleText, () {
      Future.delayed(const Duration(milliseconds: 1100), () {
        _eraseText(() {
          _currentSampleIndex = (_currentSampleIndex + 1) % _sampleAmounts.length;
          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted && !_isFilled) {
              _startTypingAnimation();
            }
          });
        });
      });
    });
  }
  
  void _typeText(String text, VoidCallback onComplete) {
    int currentIndex = 0;
    
    Timer.periodic(const Duration(milliseconds: 160), (timer) {
      if (currentIndex < text.length && mounted) {
        setState(() {
          _controller.text = text.substring(0, currentIndex + 1) + '€';
        });
        currentIndex++;
      } else {
        timer.cancel();
        _isAnimating = false;
        onComplete();
      }
    });
  }
  
  void _eraseText(VoidCallback onComplete) {
    String currentText = _controller.text.replaceAll('€', '');
    
    Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (currentText.isNotEmpty && mounted) {
        currentText = currentText.substring(0, currentText.length - 1);
        setState(() {
          _controller.text = currentText + '€';
        });
      } else {
        timer.cancel();
        onComplete();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: TextField(
        controller: _controller,
        style: TextStyle(
          fontSize: 64,
          fontWeight: FontWeight.w700,
          color: _isFilled ? Colors.white : const Color(0xFF434343),
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,€]')),
        ],
        onChanged: (value) {
          if (!_isFilled) {
            setState(() {
              _isFilled = true;
              _isAnimating = false;
            });
          }
          
          // Parse amount and update state
          final cleanValue = value.replaceAll('€', '').replaceAll(',', '.');
          final amount = double.tryParse(cleanValue) ?? 0.0;
          
          context.read<AppState>().setAmount(amount);
        },
        onTap: () {
          if (!_isFilled) {
            setState(() {
              _isFilled = true;
              _isAnimating = false;
            });
          }
          
          // Position cursor before €
          final text = _controller.text;
          final cursorPosition = text.length - 1;
          _controller.selection = TextSelection.collapsed(offset: cursorPosition);
        },
      ),
    );
  }
}
