import 'package:flutter/material.dart';

abstract class ScreenBase<T extends StatefulWidget> extends State<T> {
  bool isLoading = false;
  String? errorMessage;

  void setLoading(bool loading) {
    setState(() {
      isLoading = loading;
    });
  }

  void setError(String? error) {
    setState(() {
      errorMessage = error;
    });
  }

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
