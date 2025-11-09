import 'package:flutter/material.dart' hide Spacer;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_ui/app_ui.dart' show showAppModal;
import 'package:demo_news/app/app.dart';
import 'package:demo_news/article/article.dart';
import 'package:demo_news/categories/categories.dart';
import 'package:demo_news/l10n/l10n.dart';
import 'package:demo_news/newsletter/newsletter.dart';
import 'package:news_blocks/news_blocks.dart';
import 'package:news_blocks_ui/news_blocks_ui.dart';

class CategoryFeedItem extends StatelessWidget {
  const CategoryFeedItem({required this.block, super.key});

  /// The associated [NewsBlock] instance.
  final NewsBlock block;

  @override
  Widget build(BuildContext context) {
    final newsBlock = block;

    final isUserSubscribed =
        context.select((AppBloc bloc) => bloc.state.isUserSubscribed);

    late Widget widget;

    if (newsBlock is DividerHorizontalBlock) {
      widget = DividerHorizontal(block: newsBlock);
    } else if (newsBlock is SpacerBlock) {
      widget = Spacer(block: newsBlock);
    } else if (newsBlock is SectionHeaderBlock) {
      widget = SectionHeader(
        block: newsBlock,
        onPressed: (action) => _onFeedItemAction(context, action),
      );
    } else if (newsBlock is PostLargeBlock) {
      widget = PostLarge(
        block: newsBlock,
        premiumText: context.l10n.newsBlockPremiumText,
        isLocked: newsBlock.isPremium && !isUserSubscribed,
        onPressed: (action) => _onFeedItemAction(context, action),
        onSummary: () => _showSummaryModal(context, newsBlock.title),
        onFactCheck: () => _showFactCheckModal(context, newsBlock.title),
      );
    } else if (newsBlock is PostMediumBlock) {
      widget = PostMedium(
        block: newsBlock,
        onPressed: (action) => _onFeedItemAction(context, action),
        onSummary: () => _showSummaryModal(context, newsBlock.title),
        onFactCheck: () => _showFactCheckModal(context, newsBlock.title),
      );
    } else if (newsBlock is PostSmallBlock) {
      widget = PostSmall(
        block: newsBlock,
        onPressed: (action) => _onFeedItemAction(context, action),
        onSummary: () => _showSummaryModal(context, newsBlock.title),
        onFactCheck: () => _showFactCheckModal(context, newsBlock.title),
      );
    } else if (newsBlock is PostGridGroupBlock) {
      widget = PostGrid(
        gridGroupBlock: newsBlock,
        premiumText: context.l10n.newsBlockPremiumText,
        onPressed: (action) => _onFeedItemAction(context, action),
      );
    } else if (newsBlock is NewsletterBlock) {
      widget = const Newsletter();
    } else if (newsBlock is BannerAdBlock) {
      widget = BannerAd(
        block: newsBlock,
        adFailedToLoadTitle: context.l10n.adLoadFailure,
      );
    } else {
      // Render an empty widget for the unsupported block type.
      widget = const SizedBox();
    }

    return (newsBlock is! PostGridGroupBlock)
        ? SliverToBoxAdapter(child: widget)
        : widget;
  }

  /// Handles actions triggered by tapping on feed items.
  Future<void> _onFeedItemAction(
    BuildContext context,
    BlockAction action,
  ) async {
    if (action is NavigateToArticleAction) {
      await Navigator.of(context).push<void>(
        ArticlePage.route(id: action.articleId),
      );
    } else if (action is NavigateToVideoArticleAction) {
      await Navigator.of(context).push<void>(
        ArticlePage.route(id: action.articleId, isVideoArticle: true),
      );
    } else if (action is NavigateToFeedCategoryAction) {
      context
          .read<CategoriesBloc>()
          .add(CategorySelected(category: action.category));
    }
  }

  /// Shows a modal with article summary.
  void _showSummaryModal(BuildContext context, String title) {
    showAppModal<void>(
      context: context,
      builder: (context) => SummaryModal(
        title: title,
        summary: _generateSummary(title),
      ),
    );
  }

  /// Shows a modal with article fact check.
  void _showFactCheckModal(BuildContext context, String title) {
    showAppModal<void>(
      context: context,
      builder: (context) => FactCheckModal(
        title: title,
        factCheck: _generateFactCheck(title),
      ),
    );
  }

  /// Generates a summary for the article.
  /// To-Do: Replace with actual AI-generated summary.
  String _generateSummary(String title) {
    return 'This is a placeholder summary for the article titled "$title".\n\n'
        'Key points:\n'
        '• Main topic and context of the story\n'
        '• Important facts and figures\n'
        '• Key people or organizations involved\n'
        '• Implications and significance\n\n'
        'Note: This is a demo implementation. Replace this method with\n'
        'actual API calls to generate summaries using AI services.';
  }

  /// Generates a fact check for the article.
  /// To-Do: Replace with actual AI-generated fact check.
  String _generateFactCheck(String title) {
    return 'This is a placeholder fact check for the article titled "$title".\n\n'
        'Fact-checked claims:\n'
        '✓ Claim 1: Verified and accurate\n'
        '✓ Claim 2: Verified with reliable sources\n'
        '⚠ Claim 3: Partially accurate, requires context\n\n'
        'Sources consulted:\n'
        '• Primary source documents\n'
        '• Expert verification\n'
        '• Historical records\n\n'
        'Note: This is a demo implementation. Replace this method with\n'
        'actual API calls to perform fact-checking using AI services.';
  }
}
