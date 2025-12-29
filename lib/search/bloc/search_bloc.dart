import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_blocks/news_blocks.dart';
import 'package:news_repository/news_repository.dart';
import 'package:stories_repository/stories_repository.dart';
import 'package:stream_transform/stream_transform.dart';

part 'search_event.dart';
part 'search_state.dart';

const _duration = Duration(milliseconds: 300);

EventTransformer<Event> restartableDebounce<Event>(
  Duration duration, {
  required bool Function(Event) isDebounced,
}) {
  return (events, mapper) {
    final debouncedEvents = events.where(isDebounced).debounce(duration);
    final otherEvents = events.where((event) => !isDebounced(event));
    return otherEvents.merge(debouncedEvents).switchMap(mapper);
  };
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({
    required NewsRepository newsRepository,
    required StoriesRepository storiesRepository,
  })  : _newsRepository = newsRepository,
        _storiesRepository = storiesRepository,
        super(const SearchState.initial()) {
    on<SearchTermChanged>(
      (event, emit) async {
        event.searchTerm.isEmpty
            ? await _onEmptySearchRequested(event, emit)
            : await _onSearchTermChanged(event, emit);
      },
      transformer: restartableDebounce(
        _duration,
        isDebounced: (event) => event.searchTerm.isNotEmpty,
      ),
    );
  }

  final NewsRepository _newsRepository;
  final StoriesRepository _storiesRepository;

  FutureOr<void> _onEmptySearchRequested(
    SearchTermChanged event,
    Emitter<SearchState> emit,
  ) async {
    emit(
      state.copyWith(
        status: SearchStatus.loading,
        searchType: SearchType.popular,
      ),
    );
    try {
      // Get recent stories when search is empty
      final response = await _storiesRepository.getStories(
        limit: 20,
        offset: 0,
      );

      emit(
        state.copyWith(
          stories: response.stories,
          articles: const [],
          topics: const [],
          status: SearchStatus.populated,
        ),
      );
    } catch (error, stackTrace) {
      emit(state.copyWith(status: SearchStatus.failure));
      addError(error, stackTrace);
    }
  }

  FutureOr<void> _onSearchTermChanged(
    SearchTermChanged event,
    Emitter<SearchState> emit,
  ) async {
    emit(
      state.copyWith(
        status: SearchStatus.loading,
        searchType: SearchType.relevant,
      ),
    );
    try {
      // Search stories from Supabase
      final stories = await _storiesRepository.searchStories(
        term: event.searchTerm,
      );

      emit(
        state.copyWith(
          stories: stories,
          articles: const [],
          topics: const [],
          status: SearchStatus.populated,
        ),
      );
    } catch (error, stackTrace) {
      emit(state.copyWith(status: SearchStatus.failure));
      addError(error, stackTrace);
    }
  }
}
