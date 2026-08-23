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

    test('getPlanById returns the matching plan', () {
      final proverbs = ReadingPlanService.getPlanById('proverbs_31');
      expect(proverbs, isNotNull);
      expect(proverbs!.id, equals('proverbs_31'));
      expect(proverbs.totalDays, equals(31));
    });

    test('getPlanById returns null for an unknown id', () {
      // It used to fall back to availablePlans.first, which silently handed
      // callers a different plan than the one they asked for.
      expect(ReadingPlanService.getPlanById('non_existent_id'), isNull);
    });
  });
}
