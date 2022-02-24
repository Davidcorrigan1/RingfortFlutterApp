import 'package:flutter/material.dart';

class TextBox extends StatelessWidget {
  final double height;
  final String displayText;

  const TextBox({
    this.height,
    this.displayText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Theme.of(context).primaryColor,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(5.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          displayText,
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
