import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:news_repository/news_repository.dart';
import 'package:stories_repository/stories_repository.dart';

part 'categories_event.dart';
part 'categories_state.dart';
part 'categories_bloc.g.dart';

class CategoriesBloc extends HydratedBloc<CategoriesEvent, CategoriesState> {
  CategoriesBloc({
    required NewsRepository newsRepository,
    required StoriesRepository storiesRepository,
  })  : _newsRepository = newsRepository,
        _storiesRepository = storiesRepository,
        super(const CategoriesState.initial()) {
    on<CategoriesRequested>(_onCategoriesRequested);
    on<CategorySelected>(_onCategorySelected);
  }

  final NewsRepository _newsRepository;
  final StoriesRepository _storiesRepository;

  FutureOr<void> _onCategoriesRequested(
    CategoriesRequested event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(state.copyWith(status: CategoriesStatus.loading));
    try {
      // Fetch categories from Supabase stories table
      final categoryStrings = await _storiesRepository.getCategories();

      // Convert string categories to Category enum
      final categories = categoryStrings
          .map((categoryString) {
            try {
              return Category.fromString(categoryString);
            } catch (e) {
              // Skip invalid categories
              return null;
            }
          })
          .whereType<Category>()
          .toList();

      // Add 'top' category if not already present
      if (!categories.contains(Category.top)) {
        categories.insert(0, Category.top);
      }

      // Default to 'top' category
      final defaultCategory = Category.top;

      emit(
        state.copyWith(
          status: CategoriesStatus.populated,
          categories: categories,
          selectedCategory: defaultCategory,
        ),
      );
    } catch (error, stackTrace) {
      emit(state.copyWith(status: CategoriesStatus.failure));
      addError(error, stackTrace);
    }
  }

  void _onCategorySelected(
    CategorySelected event,
    Emitter<CategoriesState> emit,
  ) =>
      emit(state.copyWith(selectedCategory: event.category));

  @override
  CategoriesState? fromJson(Map<String, dynamic> json) =>
      CategoriesState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(CategoriesState state) => state.toJson();
}
