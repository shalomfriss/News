import 'package:app_ui/app_ui.dart';
import 'package:demo_news/feed/feed.dart';
import 'package:demo_news/network_error/network_error.dart';
import 'package:demo_news_api/client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Custom scroll physics that reduces the scroll velocity/sensitivity
class _ReducedVelocityScrollPhysics extends ScrollPhysics {
  const _ReducedVelocityScrollPhysics({super.parent});

  @override
  _ReducedVelocityScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _ReducedVelocityScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // Reduce scroll sensitivity by scaling down the offset
    return super.applyPhysicsToUserOffset(position, offset * 0.5);
  }

  @override
  double get minFlingVelocity => 50; // Increase minimum fling velocity

  @override
  double carriedMomentum(double existingVelocity) {
    // Reduce momentum by 70%
    return super.carriedMomentum(existingVelocity) * 0.3;
  }

  @override
  bool get allowImplicitScrolling => true;
}

class CategoryFeed extends StatelessWidget {
  const CategoryFeed({
    required this.category,
    this.scrollController,
    super.key,
  });

  final Category category;

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final categoryFeed =
        context.select((FeedBloc bloc) => bloc.state.feed[category]) ?? [];

    final hasMoreNews =
        context.select((FeedBloc bloc) => bloc.state.hasMoreNews[category]) ??
            true;

    final isFailure = context
        .select((FeedBloc bloc) => bloc.state.status == FeedStatus.failure);

    return BlocListener<FeedBloc, FeedState>(
      listener: (context, state) {
        if (state.status == FeedStatus.failure && state.feed.isEmpty) {
          Navigator.of(context).push<void>(
            NetworkError.route(
              onRetry: () {
                context
                    .read<FeedBloc>()
                    .add(FeedRefreshRequested(category: category));
                Navigator.of(context).pop();
              },
            ),
          );
        }
      },
      child: RefreshIndicator(
        onRefresh: () async => context
            .read<FeedBloc>()
            .add(FeedRefreshRequested(category: category)),
        displacement: 0,
        color: AppColors.mediumHighEmphasisSurface,
        child: SelectionArea(
          child: CustomScrollView(
            controller: scrollController,
            physics: const _ReducedVelocityScrollPhysics(),
            slivers: _buildSliverItems(
              context,
              categoryFeed,
              hasMoreNews,
              isFailure,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSliverItems(
    BuildContext context,
    List<NewsBlock> categoryFeed,
    bool hasMoreNews,
    bool isFailure,
  ) {
    final sliverList = <Widget>[];

    for (var index = 0; index < categoryFeed.length + 1; index++) {
      late Widget result;
      if (index == categoryFeed.length) {
        if (isFailure) {
          result = NetworkError(
            onRetry: () {
              context
                  .read<FeedBloc>()
                  .add(FeedRefreshRequested(category: category));
            },
          );
        } else {
          result = hasMoreNews
              ? Padding(
                  padding: EdgeInsets.only(
                    top: categoryFeed.isEmpty ? AppSpacing.xxxlg : 0,
                  ),
                  child: CategoryFeedLoaderItem(
                    key: ValueKey(index),
                    onPresented: () => context
                        .read<FeedBloc>()
                        .add(FeedRequested(category: category)),
                  ),
                )
              : const SizedBox();
        }

        sliverList.add(SliverToBoxAdapter(child: result));
      } else {
        final block = categoryFeed[index];
        sliverList.add(CategoryFeedItem(block: block));
      }
    }

    return sliverList;
  }
}
