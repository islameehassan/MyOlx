import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class loading extends StatelessWidget {
  const loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white70,
      child: const Center(
        child: SpinKitFadingCircle(
          color: Colors.black,
          size: 50.0,
        ),
      ),
    );
  }
}
