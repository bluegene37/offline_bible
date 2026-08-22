import 'package:flutter_test/flutter_test.dart';
import 'package:offline_bible/core/services/reading_plan_service.dart';

void main() {
  group('ReadingPlanService Unit Tests', () {
    test('Available plans are non-empty and valid', () {
      final plans = ReadingPlanService.availablePlans;
      expect(plans.isNotEmpty, isTrue);

      for (final plan in plans) {
        expect(plan.id.isNotEmpty, isTrue);
        expect(plan.title.isNotEmpty, isTrue);
        expect(plan.totalDays, equals(plan.days.length));
      }
    });

    test('getPlanById returns correct plan or default', () {
      final proverbs = ReadingPlanService.getPlanById('proverbs_31');
      expect(proverbs, isNotNull);
      expect(proverbs!.id, equals('proverbs_31'));
      expect(proverbs.totalDays, equals(31));

      final unknown = ReadingPlanService.getPlanById('non_existent_id');
      expect(unknown, isNotNull);
      expect(unknown!.id, equals(ReadingPlanService.availablePlans.first.id));
    });
  });
}
