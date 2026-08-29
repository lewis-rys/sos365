import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> makeCall(String number) async {
  final uri = Uri(scheme: 'tel', path: number);
  if (await canLaunchUrl(uri)) await launchUrl(uri);
}

void updateSlider(
  DragUpdateDetails d,
  double sliderWidth,
  double knobSize,
  void Function(void Function()) setState,
  Function(double) setValue,
  double current,
) {
  setState(() {
    double value = current + d.delta.dx;
    setValue(value.clamp(0, sliderWidth - knobSize - 10));
  });
}

void handleSliderEnd(double position, double sliderWidth, VoidCallback reset) {
  if (position > sliderWidth * 0.6) makeCall("911");
  Future.delayed(const Duration(milliseconds: 600), reset);
}

void resetSlider(
  void Function(void Function()) setState,
  VoidCallback resetValue,
) {
  setState(resetValue);
}
