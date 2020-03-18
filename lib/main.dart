import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:slider_demo/toast.dart';

String rawCookie;
Map<String, String> headers = {};
int width = 0;
double containerWidth;
double containerHeight;
double sliderWidth;
double sliderHeight;
bool showLoading = false;

void main() => runApp(MyApp());

MemoryImage imageFromBase64String(String base64String) {
  return MemoryImage(
    base64Decode(base64String),
  );
}

Future<ui.Image> getImageInfo(String base64String) async {
  Completer<ui.Image> completer = new Completer<ui.Image>();
  imageFromBase64String(base64String)
      .resolve(
        ImageConfiguration(),
      )
      .addListener(
        ImageStreamListener(
          (ImageInfo info, bool _) => completer.complete(info.image),
        ),
      );

  return completer.future;
}

void updateCookie(http.Response response) {
  rawCookie = response.headers['set-cookie'];
  print('rawCookie====$rawCookie');
  if (rawCookie != null) {
    int index = rawCookie.indexOf(';');
    headers['cookie'] =
        (index == -1) ? rawCookie : rawCookie.substring(0, index);
  }
}

void login({BuildContext context}) async {
  Map<String, String> data = {
    'username': 'benjamin02',
    'password': 'a123456',
    'width': width.toString(),
  };

  var url = 'http://192.168.31.99:28082/api/login';
//  print('data ============ ${jsonEncode(data)}');
  http.Response res = await http.post(
    url,
    body: data,
    headers: headers,
  );
  updateCookie(res);
  Map loginRes = jsonDecode(res.body);
  if (loginRes['error'] == 0) {
//    showLoading = false;
  } else if (loginRes['error'] == 1) {
    Toast.show(context, '${loginRes['message']}');
//    showLoading = false;
  }

  print('res=====${res.body}');
//  print('headers3======$headers');
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ModalProgressHUD(
          inAsyncCall: showLoading,
          child: Center(
            child: Slider(),
          ),
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
  int yHeight = 0;

  ValueNotifier<double> valueListener = ValueNotifier(.0);

  String movingDistance = '0.0';

  String background = '';

  String slider = '';

  void requireSlider() async {
    String url =
        'http://192.168.31.99:28082/api/need-security-code?username=benjamin02';
    http.Response response = await http.get(url);

    updateCookie(response);

    Map requireSliderRes = jsonDecode(response.body);

    if (requireSliderRes['error'] == 0) {
      Map dataBody = requireSliderRes['data'];
      if (dataBody['needSecurityCode']) {
        setState(() {
          background = dataBody['backImage'];
          slider = dataBody['slidingImage'];
          yHeight = dataBody['yHeight'];
        });

        print('yHeight=====$yHeight');

        ui.Image containerInfo = await getImageInfo(background);

        setState(() {
          containerHeight = containerInfo.height.toDouble();
          containerWidth = containerInfo.width.toDouble();
        });

        ui.Image sliderInfo = await getImageInfo(slider);
        setState(() {
          sliderHeight = sliderInfo.height.toDouble();
          sliderWidth = sliderInfo.width.toDouble();
        });
      }
    }
  }

  void notifyParent() {
    if (widget.valueChanged != null) {
      widget.valueChanged(valueListener.value);
    }
  }

  @override
  void initState() {
    valueListener.addListener(notifyParent);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          onPressed: () {
            requireSlider();
          },
          child: Text('require'),
        ),
        RaisedButton(
          onPressed: () {
            login(context: context);
          },
          child: Text('login'),
        ),
        Container(
          decoration: BoxDecoration(
            image: background == ''
                ? null
                : DecorationImage(
                    image: imageFromBase64String(background),
                    fit: BoxFit.contain,
                  ),
          ),
          height: containerHeight,
          width: containerWidth,
          margin: EdgeInsets.symmetric(horizontal: 40.0),
          child: SliderBlock(
            sliderImage: slider,
            yHeight: yHeight,
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

class SliderBlock extends StatefulWidget {
  final String sliderImage;
  final int yHeight;

  const SliderBlock({Key key, this.sliderImage, this.yHeight = 0})
      : super(key: key);
  @override
  _SliderBlockState createState() => _SliderBlockState();
}

class _SliderBlockState extends State<SliderBlock> {
  ValueNotifier<double> valueListener = ValueNotifier(.0);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final handle = GestureDetector(
          onHorizontalDragUpdate: (details) {
            valueListener.value =
                (valueListener.value + details.delta.dx / context.size.width)
                    .clamp(.0, 1.0);
          },
          onHorizontalDragEnd: (details) {
            width =
                (valueListener.value * (containerWidth - sliderWidth)).toInt();

            print('width =====$width');
            print('showLoading111===$showLoading');

            setState(() {
              showLoading = true;
            });
            print('showLoading222===$showLoading');
            login(context: context);
          },
          child: Container(
            decoration: BoxDecoration(
              image: widget.sliderImage == ''
                  ? null
                  : DecorationImage(
                      image: imageFromBase64String(widget.sliderImage),
                      fit: BoxFit.contain,
                    ),
//              color: Colors.red,
            ),
            width: sliderWidth,
            height: sliderHeight,
          ),
        );

        return AnimatedBuilder(
          animation: valueListener,
          builder: (context, child) {
            return Align(
              alignment: Alignment(
                  valueListener.value * 2 - 1, -1 + widget.yHeight / 45),
              child: child,
            );
          },
          child: handle,
        );
      },
    );
  }
}
