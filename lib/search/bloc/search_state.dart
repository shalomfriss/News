part of 'search_bloc.dart';

enum SearchStatus {
  initial,
  loading,
  populated,
  failure,
}

enum SearchType {
  popular,
  relevant,
}

class SearchState extends Equatable {
  const SearchState({
    required this.articles,
    required this.topics,
    required this.status,
    required this.searchType,
    this.stories = const [],
  });

  const SearchState.initial()
      : this(
          articles: const [],
          topics: const [],
          status: SearchStatus.initial,
          searchType: SearchType.popular,
          stories: const [],
        );

  final List<NewsBlock> articles;

  final List<String> topics;

  final SearchStatus status;

  final SearchType searchType;

  final List<Story> stories;

  @override
  List<Object?> get props => [articles, topics, status, searchType, stories];

  SearchState copyWith({
    List<NewsBlock>? articles,
    List<String>? topics,
    SearchStatus? status,
    SearchType? searchType,
    List<Story>? stories,
  }) =>
      SearchState(
        articles: articles ?? this.articles,
        topics: topics ?? this.topics,
        status: status ?? this.status,
        searchType: searchType ?? this.searchType,
        stories: stories ?? this.stories,
      );
}
