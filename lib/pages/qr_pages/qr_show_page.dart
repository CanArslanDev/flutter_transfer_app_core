/*
 * QR.Flutter
 * Copyright (c) 2019 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_fast_transfer_firebase_core/core/firebase_core.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// This is the screen that you'll see when the app starts
class QRShowPage extends StatelessWidget {
  const QRShowPage({super.key});

  @override
  Widget build(BuildContext context) {
    final encodedString = jsonEncode(
      FirebaseCore().getConnectionDataForQRConnectionRequest(),
    );

    return Material(
      color: Colors.white,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: SizedBox(
                  width: 200,
                  child: CustomPaint(
                    size: const Size.square(200),
                    painter: QrPainter(
                      data: encodedString,
                      version: QrVersions.auto,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xff128760),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.circle,
                        color: Color(0xff1a5441),
                      ),
                      embeddedImageStyle: const QrEmbeddedImageStyle(
                        size: Size.square(60),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
