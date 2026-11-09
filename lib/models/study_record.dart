class StudyRecord {
  const StudyRecord({
    required this.correctCount,
    required this.totalCount,
    required this.elapsedSeconds,
  });

  final int correctCount;
  final int totalCount;
  final int elapsedSeconds;

  Map<String, dynamic> toJson() {
    return {
      'correctCount': correctCount,
      'totalCount': totalCount,
      'elapsedSeconds': elapsedSeconds,
    };
  }

  factory StudyRecord.fromJson(
    Map<String, dynamic> json,
  ) {
    return StudyRecord(
      correctCount:
          json['correctCount'] as int,
      totalCount:
          json['totalCount'] as int,
      elapsedSeconds:
          json['elapsedSeconds'] as int,
    );
  }
}