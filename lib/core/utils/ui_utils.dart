import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UiUtils {
  static void showConfirmationDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
