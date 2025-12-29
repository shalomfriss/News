import 'package:equatable/equatable.dart';
import 'package:stories_repository/src/models/story.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// {@template stories_failure}
/// Base failure class for the stories repository failures.
/// {@endtemplate}
abstract class StoriesFailure with EquatableMixin implements Exception {
  /// {@macro stories_failure}
  const StoriesFailure(this.error);

  /// The error which was caught.
  final Object error;

  @override
  List<Object?> get props => [error];
}

/// {@template get_stories_failure}
/// Thrown when fetching stories fails.
/// {@endtemplate}
class GetStoriesFailure extends StoriesFailure {
  /// {@macro get_stories_failure}
  const GetStoriesFailure(super.error);
}

/// {@template stories_response}
/// Response object containing stories and pagination info.
/// {@endtemplate}
class StoriesResponse extends Equatable {
  /// {@macro stories_response}
  const StoriesResponse({
    required this.stories,
    required this.totalCount,
    required this.hasMore,
  });

  /// The list of stories.
  final List<Story> stories;

  /// The total number of stories available.
  final int totalCount;

  /// Whether there are more stories to fetch.
  final bool hasMore;

  @override
  List<Object> get props => [stories, totalCount, hasMore];
}

/// {@template stories_repository}
/// A repository that manages stories data from Supabase.
/// {@endtemplate}
class StoriesRepository {
  /// {@macro stories_repository}
  StoriesRepository({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  /// Fetches stories from Supabase with pagination.
  ///
  /// Parameters:
  /// * [limit] - The number of stories to fetch (default: 10)
  /// * [offset] - The offset for pagination (default: 0)
  /// * [category] - Optional category filter
  Future<StoriesResponse> getStories({
    int limit = 10,
    int offset = 0,
    String? category,
  }) async {
    try {
      // Build the query
      var query = _supabaseClient
          .from('stories')
          .select();

      // Add category filter if provided (must be before range)
      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      // Execute the query with pagination
      final response = await query
          .range(offset, offset + limit - 1) as List<dynamic>;

      // Parse the response
      final stories = response
          .map((json) => Story.fromJson(json as Map<String, dynamic>))
          .toList();

      // If we got a full page of results, there might be more
      final hasMore = stories.length == limit;

      return StoriesResponse(
        stories: stories,
        totalCount: offset + stories.length,
        hasMore: hasMore,
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(GetStoriesFailure(error), stackTrace);
    }
  }

  /// Fetches a single story by ID.
  Future<Story> getStoryById(String id) async {
    try {
      final response = await _supabaseClient
          .from('stories')
          .select()
          .eq('id', id)
          .single();

      return Story.fromJson(response);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(GetStoriesFailure(error), stackTrace);
    }
  }

  /// Fetches distinct categories from stories.
  Future<List<String>> getCategories() async {
    try {
      final response = await _supabaseClient
          .from('stories')
          .select('category')
          .not('category', 'is', null);

      final categories = <String>{};
      for (final item in response as List<dynamic>) {
        final category = item['category'] as String?;
        if (category != null && category.isNotEmpty) {
          categories.add(category);
        }
      }

      return categories.toList()..sort();
    } catch (error, stackTrace) {
      print('❌ Error fetching categories: $error');
      Error.throwWithStackTrace(GetStoriesFailure(error), stackTrace);
    }
  }

  /// Searches stories by term in summary, accuracy_assessment, and other fields.
  Future<List<Story>> searchStories({required String term}) async {
    try {
      if (term.isEmpty) {
        return [];
      }

      final response = await _supabaseClient
          .from('stories')
          .select()
          .or(
            'summary.ilike.%$term%,'
            'accuracy_assessment.ilike.%$term%,'
            'propaganda_indicators.ilike.%$term%',
          )
          .order('created_at', ascending: false)
          .limit(20);

      final stories = (response as List<dynamic>)
          .map((json) => Story.fromJson(json as Map<String, dynamic>))
          .toList();

      return stories;
    } catch (error, stackTrace) {
      print('❌ Error searching stories: $error');
      Error.throwWithStackTrace(GetStoriesFailure(error), stackTrace);
    }
  }
}
