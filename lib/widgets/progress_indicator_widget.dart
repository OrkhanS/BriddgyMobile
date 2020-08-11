import 'package:flutter/material.dart';

class ProgressIndicatorWidget extends StatefulWidget {
  final bool show;
  ProgressIndicatorWidget({@required this.show});
  @override
  _ProgressIndicatorWidgetState createState() => _ProgressIndicatorWidgetState();
}

class _ProgressIndicatorWidgetState extends State<ProgressIndicatorWidget> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.bottomCenter,
      child: Container(
        height: widget.show ? 50.0 : 0.0,
        margin: EdgeInsets.all(20),
        width: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Color.fromRGBO(0, 115, 100, 100),
        ),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }
}
