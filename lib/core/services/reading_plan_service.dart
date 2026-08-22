import '../services/storage_service.dart';

class ReadingPlanDay {
  final int day;
  final String title;
  final String book;
  final int chapter;
  final String? verseRange;

  const ReadingPlanDay({
    required this.day,
    required this.title,
    required this.book,
    required this.chapter,
    this.verseRange,
  });
}

class ReadingPlan {
  final String id;
  final String title;
  final String description;
  final String category;
  final int totalDays;
  final List<ReadingPlanDay> days;

  const ReadingPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.totalDays,
    required this.days,
  });

  bool isDayCompleted(int dayNumber) {
    final completedDays = getCompletedDays();
    return completedDays.contains(dayNumber);
  }

  Set<int> getCompletedDays() {
    final raw = StorageService.readingPlansBox.get(id, defaultValue: <dynamic>[]);
    if (raw is List) {
      return raw.map((e) => int.tryParse(e.toString()) ?? 0).where((d) => d > 0).toSet();
    }
    return {};
  }

  double get progressPercentage {
    final completed = getCompletedDays().length;
    if (totalDays == 0) return 0.0;
    return (completed / totalDays).clamp(0.0, 1.0);
  }

  Future<void> toggleDayCompletion(int dayNumber) async {
    final completed = getCompletedDays();
    if (completed.contains(dayNumber)) {
      completed.remove(dayNumber);
    } else {
      completed.add(dayNumber);
    }
    await StorageService.readingPlansBox.put(id, completed.toList());
  }
}

class ReadingPlanService {
  static final List<ReadingPlan> availablePlans = [
    ReadingPlan(
      id: 'proverbs_31',
      title: '31 Days of Wisdom',
      description: 'Read one chapter of Proverbs every day for month-long wisdom.',
      category: 'Wisdom',
      totalDays: 31,
      days: List.generate(
        31,
        (i) => ReadingPlanDay(
          day: i + 1,
          title: 'Proverbs Chapter ${i + 1}',
          book: 'Proverbs',
          chapter: i + 1,
        ),
      ),
    ),
    ReadingPlan(
      id: 'psalms_peace_14',
      title: '14 Days of Peace & Comfort',
      description: 'Uplifting Psalms selected to bring peace, reassurance, and hope.',
      category: 'Psalms',
      totalDays: 14,
      days: const [
        ReadingPlanDay(day: 1, title: 'The Lord is My Shepherd', book: 'Psalms', chapter: 23),
        ReadingPlanDay(day: 2, title: 'God is Our Refuge', book: 'Psalms', chapter: 46),
        ReadingPlanDay(day: 3, title: 'Dwelling in Safety', book: 'Psalms', chapter: 91),
        ReadingPlanDay(day: 4, title: 'Praise the Lord', book: 'Psalms', chapter: 103),
        ReadingPlanDay(day: 5, title: 'My Help Comes From the Lord', book: 'Psalms', chapter: 121),
        ReadingPlanDay(day: 6, title: 'I Will Bless the Lord', book: 'Psalms', chapter: 34),
        ReadingPlanDay(day: 7, title: 'Create in Me a Clean Heart', book: 'Psalms', chapter: 51),
        ReadingPlanDay(day: 8, title: 'The Earth is the Lord\'s', book: 'Psalms', chapter: 24),
        ReadingPlanDay(day: 9, title: 'Wait on the Lord', book: 'Psalms', chapter: 27),
        ReadingPlanDay(day: 10, title: 'O Lord, Our Lord', book: 'Psalms', chapter: 8),
        ReadingPlanDay(day: 11, title: 'Delight Yourself in the Lord', book: 'Psalms', chapter: 37),
        ReadingPlanDay(day: 12, title: 'How Lovely is Your Dwelling Place', book: 'Psalms', chapter: 84),
        ReadingPlanDay(day: 13, title: 'Search Me, O God', book: 'Psalms', chapter: 139),
        ReadingPlanDay(day: 14, title: 'Praise Him with Everything', book: 'Psalms', chapter: 150),
      ],
    ),
    ReadingPlan(
      id: 'gospels_john_21',
      title: '21 Days with Jesus (Gospel of John)',
      description: 'Discover the life, miracles, and love of Jesus in John.',
      category: 'Gospels',
      totalDays: 21,
      days: List.generate(
        21,
        (i) => ReadingPlanDay(
          day: i + 1,
          title: 'John Chapter ${i + 1}',
          book: 'John',
          chapter: i + 1,
        ),
      ),
    ),
    ReadingPlan(
      id: 'epistles_paul_10',
      title: '10 Days in Philippians & Colossians',
      description: 'Key epistles filled with joy, gratitude, and spiritual strength.',
      category: 'Epistles',
      totalDays: 10,
      days: const [
        ReadingPlanDay(day: 1, title: 'Philippians 1 - Joy in Circumstances', book: 'Philippians', chapter: 1),
        ReadingPlanDay(day: 2, title: 'Philippians 2 - The Mind of Christ', book: 'Philippians', chapter: 2),
        ReadingPlanDay(day: 3, title: 'Philippians 3 - Pressing Toward the Goal', book: 'Philippians', chapter: 3),
        ReadingPlanDay(day: 4, title: 'Philippians 4 - Rejoice & Be Anxious for Nothing', book: 'Philippians', chapter: 4),
        ReadingPlanDay(day: 5, title: 'Colossians 1 - The Preeminence of Christ', book: 'Colossians', chapter: 1),
        ReadingPlanDay(day: 6, title: 'Colossians 2 - Alive in Christ', book: 'Colossians', chapter: 2),
        ReadingPlanDay(day: 7, title: 'Colossians 3 - Put on the New Self', book: 'Colossians', chapter: 3),
        ReadingPlanDay(day: 8, title: 'Colossians 4 - Conduct Towards Others', book: 'Colossians', chapter: 4),
        ReadingPlanDay(day: 9, title: 'Ephesians 1 - Spiritual Blessings', book: 'Ephesians', chapter: 1),
        ReadingPlanDay(day: 10, title: 'Ephesians 6 - The Armor of God', book: 'Ephesians', chapter: 6),
      ],
    ),
  ];

  static ReadingPlan? getPlanById(String id) {
    return availablePlans.firstWhere((p) => p.id == id, orElse: () => availablePlans.first);
  }
}
