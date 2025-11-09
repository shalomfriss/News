import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// {@template fact_check_modal}
/// A modal that displays a fact check analysis of an article.
/// {@endtemplate}
class FactCheckModal extends StatelessWidget {
  /// {@macro fact_check_modal}
  const FactCheckModal({
    required this.title,
    required this.factCheck,
    super.key,
  });

  /// The title of the article.
  final String title;

  /// The fact check content to display.
  final String factCheck;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: AppColors.darkBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xlg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.fact_check,
                    color: AppColors.green,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Fact Check',
                      style: theme.textTheme.headlineSmall?.apply(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: theme.textTheme.titleLarge?.apply(
                  color: AppColors.white,
                  fontWeightDelta: 2,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: SingleChildScrollView(
                  child: Text(
                    factCheck,
                    style: theme.textTheme.bodyLarge?.apply(
                      color: AppColors.mediumEmphasisPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
