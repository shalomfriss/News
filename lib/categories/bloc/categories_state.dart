part of 'categories_bloc.dart';

enum CategoriesStatus {
  initial,
  loading,
  populated,
  failure,
}

@JsonSerializable()
class CategoriesState extends Equatable {
  const CategoriesState({
    required this.status,
    this.categories,
    this.selectedCategory,
  });

  const CategoriesState.initial()
      : this(
          status: CategoriesStatus.initial,
        );

  factory CategoriesState.fromJson(Map<String, dynamic> json) =>
      _$CategoriesStateFromJson(json);

  final CategoriesStatus status;
  final List<Category>? categories;
  final Category? selectedCategory;

  @override
  List<Object?> get props => [
        status,
        categories,
        selectedCategory,
      ];

  CategoriesState copyWith({
    CategoriesStatus? status,
    List<Category>? categories,
    Object? selectedCategory = _undefined,
  }) {
    return CategoriesState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory == _undefined
          ? this.selectedCategory
          : selectedCategory as Category?,
    );
  }

  Map<String, dynamic> toJson() => _$CategoriesStateToJson(this);
}

const _undefined = Object();
