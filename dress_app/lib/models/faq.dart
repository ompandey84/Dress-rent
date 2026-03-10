class Faq {
  final String id;
  final String question;
  final String answer;
  final String category;
  final int displayOrder;
  final bool isActive;

  Faq({
    required this.id,
    required this.question,
    required this.answer,
    this.category = 'general',
    this.displayOrder = 0,
    this.isActive = true,
  });

  factory Faq.fromJson(Map<String, dynamic> json) {
    return Faq(
      id: json['id'] as String,
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      displayOrder: json['display_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
