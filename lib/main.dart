import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Slider(),
        ),
      ),
    );
  }
}

class Slider extends StatefulWidget {
  final ValueChanged<double> valueChanged;

  Slider({this.valueChanged});

  @override
  SliderState createState() {
    return new SliderState();
  }
}

class SliderState extends State<Slider> {
  ValueNotifier<double> valueListener = ValueNotifier(.0);

  String movingDistance = '0.0';

  @override
  void initState() {
    valueListener.addListener(notifyParent);
    super.initState();
  }

  void notifyParent() {
    if (widget.valueChanged != null) {
      widget.valueChanged(valueListener.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          color: Colors.green,
          height: 100.0,
          padding: EdgeInsets.symmetric(horizontal: 40.0),
          child: Builder(
            builder: (context) {
              final handle = GestureDetector(
                onHorizontalDragUpdate: (details) {
                  valueListener.value = (valueListener.value +
                          details.delta.dx / context.size.width)
                      .clamp(.0, 1.0);
                  print(
                      'The distance of slider moving from first to end ==== ${valueListener.value}');

                  setState(() {
                    movingDistance = valueListener.value.toString();
                  });
                },
                child: FlutterLogo(size: 50.0),
              );

              return AnimatedBuilder(
                animation: valueListener,
                builder: (context, child) {
                  return Align(
                    alignment: Alignment(valueListener.value * 2 - 1, .5),
                    child: child,
                  );
                },
                child: handle,
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 21.0),
          child: Text('the fucking value you want: $movingDistance'),
        ),
      ],
    );
  }
}
