import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/search_controller.dart';

class SearchHistoryList extends StatelessWidget {
  const SearchHistoryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchController = Get.find<BibleSearchController>();

    return GetBuilder<BibleSearchController>(
      builder: (controller) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 65.0),
              padding: const EdgeInsets.all(5.0),
              child: Center(
                child: Text(
                  controller.searchHistory.isNotEmpty 
                      ? 'Search History:' 
                      : 'Search History: None',
                  style: const TextStyle(fontSize: 18.0),
                ),
              ),
            ),
            Expanded(
              child: Obx(() => ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: controller.searchHistory.length,
                itemBuilder: (context, index) {
                  final reversedIndex = controller.searchHistory.length - 1 - index;
                  final historyItem = controller.searchHistory[reversedIndex];
                  final historyKeys = controller.searchHistory.keys.toList();
                  final historyKey = historyKeys[reversedIndex];

                  // Limit history to 25 items
                  if (index > 25) {
                    controller.deleteHistoryItem(historyKey);
                    return const SizedBox.shrink();
                  }

                  return Card(
                    child: ListTile(
                      title: Text(historyItem),
                      subtitle: Text(historyKey),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => controller.deleteHistoryItem(historyKey),
                      ),
                      onTap: () => controller.selectHistoryItem(historyItem),
                    ),
                  );
                },
              )),
            ),
          ],
        );
      },
    );
  }
}