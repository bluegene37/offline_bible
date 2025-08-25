import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/controllers/app_controller.dart';

class FontPreview extends StatelessWidget {
  const FontPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (controller) {
        return Text(
          'In the beginning God created the heaven and the earth.',
          style: GoogleFonts.getFont(
            controller.globalFont.value,
            fontSize: 15 + controller.fontSize.value,
          ),
        );
      },
    );
  }
}