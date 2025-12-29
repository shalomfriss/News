import 'package:equatable/equatable.dart';

/// {@template story}
/// A story fetched from Supabase stories table with fact-checking metrics.
/// {@endtemplate}
class Story extends Equatable {
  /// {@macro story}
  const Story({
    required this.id,
    this.summary,
    this.accuracyAssessment,
    this.accuracyScore,
    this.propagandaIndicators,
    this.propagandaScore,
    this.authorSources,
    this.authorSourceBias,
    this.aiSources,
    this.overallMetrics,
    this.category,
  });

  /// Creates a [Story] from JSON.
  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id']?.toString() ?? '',
      summary: json['summary'] as String?,
      accuracyAssessment: json['accuracy_assessment'] as String?,
      accuracyScore: json['accuracy_score'] as int?,
      propagandaIndicators: json['propaganda_indicators'] as String?,
      propagandaScore: json['propaganda_score'] as int?,
      authorSources: json['author_sources'] as String?,
      authorSourceBias: json['author_source_bias'] as String?,
      aiSources: json['ai_sources'] as String?,
      overallMetrics: json['overall_metrics'] as String?,
      category: json['category'] as String?,
    );
  }

  /// The unique identifier for the story.
  final String id;

  /// Summary of the story.
  final String? summary;

  /// Accuracy assessment details.
  final String? accuracyAssessment;

  /// Numerical accuracy score.
  final int? accuracyScore;

  /// Propaganda indicators found in the story.
  final String? propagandaIndicators;

  /// Numerical propaganda score.
  final int? propagandaScore;

  /// Sources from the original author.
  final String? authorSources;

  /// Bias assessment of author sources.
  final String? authorSourceBias;

  /// AI-generated or AI-verified sources.
  final String? aiSources;

  /// Overall metrics and assessment.
  final String? overallMetrics;

  /// Category of the story.
  final String? category;

  /// Converts the story to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'summary': summary,
      'accuracy_assessment': accuracyAssessment,
      'accuracy_score': accuracyScore,
      'propaganda_indicators': propagandaIndicators,
      'propaganda_score': propagandaScore,
      'author_sources': authorSources,
      'author_source_bias': authorSourceBias,
      'ai_sources': aiSources,
      'overall_metrics': overallMetrics,
      'category': category,
    };
  }

  @override
  List<Object?> get props => [
        id,
        summary,
        accuracyAssessment,
        accuracyScore,
        propagandaIndicators,
        propagandaScore,
        authorSources,
        authorSourceBias,
        aiSources,
        overallMetrics,
        category,
      ];
}
