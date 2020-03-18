import 'package:flutter/material.dart';

class Toast {
  static show(BuildContext context, String msg) {
    var overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;
    overlayEntry = new OverlayEntry(builder: (context) {
      return buildToastLayout(msg);
    });
    var toastView = ToastView();
    toastView.overlayState = overlayState;
    toastView.overlayEntry = overlayEntry;
    toastView._show();
  }

  static LayoutBuilder buildToastLayout(String msg) {
    return LayoutBuilder(builder: (context, constraints) {
      return IgnorePointer(
        ignoring: true,
        child: Container(
          child: Material(
            color: Colors.white.withOpacity(0),
            child: Container(
              child: Container(
                child: Text(
                  "$msg",
                  style: TextStyle(color: Colors.white),
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              ),
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height / 2,
                left: constraints.biggest.width * 0.2,
                right: constraints.biggest.width * 0.2,
              ),
            ),
          ),
          alignment: Alignment.bottomCenter,
        ),
      );
    });
  }
}

class ToastView {
  OverlayEntry overlayEntry;
  OverlayState overlayState;
  bool dismissed = false;

  _show() async {
    overlayState.insert(overlayEntry);
    await Future.delayed(Duration(milliseconds: 3500));
    this.dismiss();
  }

  dismiss() async {
    if (dismissed) {
      return;
    }
    this.dismissed = true;
    overlayEntry?.remove();
  }
}
