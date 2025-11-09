import 'package:flutter/material.dart';
import 'package:news_blocks/news_blocks.dart';
import 'package:news_blocks_ui/news_blocks_ui.dart';

/// {@template post_medium}
/// A reusable post medium block widget.
/// {@endtemplate}
class PostMedium extends StatelessWidget {
  /// {@macro post_medium}
  const PostMedium({
    required this.block,
    this.onPressed,
    this.onSummary,
    this.onFactCheck,
    super.key,
  });

  /// The associated [PostMediumBlock] instance.
  final PostMediumBlock block;

  /// An optional callback which is invoked when the action is triggered.
  /// A [Uri] from the associated [BlockAction] is provided to the callback.
  final BlockActionCallback? onPressed;

  /// Called when the summary button is tapped.
  final VoidCallback? onSummary;

  /// Called when the fact check button is tapped.
  final VoidCallback? onFactCheck;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          block.hasNavigationAction ? onPressed?.call(block.action!) : null,
      child: block.isContentOverlaid
          ? PostMediumOverlaidLayout(
              title: block.title,
              imageUrl: block.imageUrl!,
            )
          : PostMediumDescriptionLayout(
              title: block.title,
              imageUrl: block.imageUrl!,
              description: block.description,
              publishedAt: block.publishedAt,
              author: block.author,
              onSummary: onSummary,
              onFactCheck: onFactCheck,
            ),
    );
  }
}
