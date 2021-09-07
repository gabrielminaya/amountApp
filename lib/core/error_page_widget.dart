import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.error_outline_outlined,
        size: MediaQuery.of(context).size.width * .2,
      ),
    );
  }
}
