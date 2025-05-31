import 'package:flutter/material.dart';

class ContinueButton extends StatefulWidget {
  const ContinueButton({super.key, required this.onPressed,required this.label});

  final String label;
  final VoidCallback onPressed;

  @override
  State<ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<ContinueButton> {
  bool _animate = false;

  @override
  Widget build(BuildContext context) {
     bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        setState(() => _animate = true);

        // Delay for animation then navigate
        Future.delayed(const Duration(milliseconds: 200), () {
          widget.onPressed();
        });
      },
      child: AnimatedContainer(
        margin: EdgeInsets.only(top:10),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 145, 198, 84).withAlpha(190),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withAlpha(140),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.label,
              style: const TextStyle(color: Color.fromARGB(255, 2, 66, 14), fontSize: 16,fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 10),
            AnimatedAlign(
              alignment:
                  _animate ? Alignment.centerRight : Alignment.centerLeft,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: const Icon(Icons.arrow_forward_ios_rounded,
                  color: Color.fromARGB(255, 2, 66, 14),size: 16,),
            ),
          ],
        ),
      ),
    );
  }
}
