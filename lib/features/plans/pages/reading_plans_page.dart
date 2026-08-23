import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/reading_plan_service.dart';

class ReadingPlansPage extends StatefulWidget {
  const ReadingPlansPage({super.key});

  @override
  State<ReadingPlansPage> createState() => _ReadingPlansPageState();
}

class _ReadingPlansPageState extends State<ReadingPlansPage> {
  ReadingPlan? _selectedPlan;

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();

    // The detail view is state rather than a route, so the system back button
    // would otherwise leave the app instead of returning to the plan list.
    return PopScope(
      canPop: _selectedPlan == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _selectedPlan != null) {
          setState(() => _selectedPlan = null);
        }
      },
      child: _selectedPlan == null
          ? _buildPlansList(appController)
          : _buildPlanDetail(_selectedPlan!, appController),
    );
  }

  Widget _buildPlansList(AppController appController) {
    final isDarkMode = appController.themeMode.value;
    final primaryColor = appController.activeThemeColor;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Icon(Icons.calendar_month_rounded, color: primaryColor, size: 28),
            const SizedBox(width: 10),
            const Text(
              'Bible Reading Plans',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Daily scripture journeys to deepen your faith and build consistent reading habits.',
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 20),
        ...ReadingPlanService.availablePlans.map((plan) {
          final progress = plan.progressPercentage;
          final completedDaysCount = plan.getCompletedDays().length;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                setState(() {
                  _selectedPlan = plan;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            plan.category.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$completedDaysCount / ${plan.totalDays} Days',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      plan.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      plan.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: primaryColor.withValues(alpha: 0.15),
                      color: primaryColor,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPlanDetail(ReadingPlan plan, AppController appController) {
    final primaryColor = appController.activeThemeColor;

    // No Scaffold or AppBar here: HomePage already provides both, and nesting
    // a second pair rendered two stacked app bars.
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back to plans',
                onPressed: () => setState(() => _selectedPlan = null),
              ),
              Expanded(
                child: Text(
                  plan.title,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: plan.days.length,
            itemBuilder: (context, index) {
              final day = plan.days[index];
              final isCompleted = plan.isDayCompleted(day.day);

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCompleted
                        ? Colors.green.withValues(alpha: 0.2)
                        : primaryColor.withValues(alpha: 0.1),
                    child: isCompleted
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : Text(
                            'D${day.day}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              fontSize: 13,
                            ),
                          ),
                  ),
                  title: Text(
                    day.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text('${day.book} ${day.chapter}'),
                  trailing: IconButton(
                    icon: Icon(
                      isCompleted
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      color: isCompleted ? Colors.green : Colors.grey,
                    ),
                    onPressed: () async {
                      await plan.toggleDayCompletion(day.day);
                      setState(() {});
                    },
                  ),
                  onTap: () {
                    appController.updateBookSelection(day.book, day.chapter);
                    appController.navigateToPage(AppConstants.biblePageIndex);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
