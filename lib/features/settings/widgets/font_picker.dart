import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class FontPicker extends StatelessWidget {
  const FontPicker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final CarouselSliderController carouselController = CarouselSliderController();

    return GetBuilder<AppController>(
      builder: (controller) {
        return CarouselSlider(
          carouselController: carouselController,
          options: CarouselOptions(
            height: 60,
            initialPage: controller.globalFontIdx,
            enlargeCenterPage: true,
            enableInfiniteScroll: false,
            autoPlay: false,
          ),
          items: AppConstants.fontOptions.map((font) {
            return Builder(
              builder: (BuildContext context) {
                final isSelected = controller.globalFont.value == font;
                
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 1.0),
                  child: Card(
                    elevation: 5,
                    color: isSelected 
                        ? AppColors.themeColorShades[controller.colorSliderIdx.value]
                        : Colors.white,
                    child: InkWell(
                      onTap: () => controller.updateFont(font),
                      child: ListTile(
                        title: Text(
                          font,
                          style: GoogleFonts.getFont(
                            font,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}