import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/utils/constants.dart';

String getFormattedDateTime(num dt, {String pattern = 'MMM dd, hh:mm a'}){
  return DateFormat(pattern).format(DateTime.fromMillisecondsSinceEpoch(dt.toInt() * 1000));
}

String getIconUrl(String icon) => '$iconUrlPrefix$icon$iconUrlSuffix';

void showCustomAlertDialog({
  required BuildContext context,
  required String title,
  required String body,
  required VoidCallback onPositiveButtonClicked,
  required VoidCallback onNegativeButtonClicked,
  String positiveButtonText = 'OK',
  String negativeButtonText = 'CANCEL',
}) {
  showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(body),
        ),
        actions: [
          OutlinedButton(
            onPressed: onPositiveButtonClicked,
            child: Text(
              positiveButtonText,
            ),
          ),
          TextButton(
            onPressed: onNegativeButtonClicked,
            child: Text(
              negativeButtonText,
            ),
          )
        ],
      ));
}

showMsg(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));
}