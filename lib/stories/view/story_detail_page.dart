import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:stories_repository/stories_repository.dart';

class StoryDetailPage extends StatelessWidget {
  const StoryDetailPage({required this.story, super.key});

  final Story story;

  static Route<void> route({required Story story}) {
    return MaterialPageRoute(
      builder: (_) => StoryDetailPage(story: story),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (story.summary != null) ...[
              Text(
                story.summary!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (story.category != null) ...[
              Chip(
                label: Text(
                  story.category!.toUpperCase(),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                if (story.accuracyScore != null) ...[
                  _ScoreChip(
                    label: 'Accuracy',
                    score: story.accuracyScore!,
                    icon: Icons.fact_check,
                  ),
                  const SizedBox(width: 8),
                ],
                if (story.propagandaScore != null) ...[
                  _ScoreChip(
                    label: 'Propaganda',
                    score: story.propagandaScore!,
                    icon: Icons.warning,
                    isWarning: true,
                  ),
                ],
              ],
            ),
            if (story.accuracyAssessment != null) ...[
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Accuracy Assessment'),
              const SizedBox(height: 8),
              MarkdownBody(
                data: story.accuracyAssessment!,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(fontSize: 16),
                  listBullet: const TextStyle(fontSize: 16),
                ),
              ),
            ],
            if (story.propagandaIndicators != null) ...[
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Propaganda Indicators'),
              const SizedBox(height: 8),
              MarkdownBody(
                data: story.propagandaIndicators!,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(fontSize: 16),
                  listBullet: const TextStyle(fontSize: 16),
                ),
              ),
            ],
            if (story.authorSources != null) ...[
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Author Sources'),
              const SizedBox(height: 8),
              MarkdownBody(
                data: story.authorSources!,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(fontSize: 16),
                  listBullet: const TextStyle(fontSize: 16),
                ),
              ),
              if (story.authorSourceBias != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Bias: ${story.authorSourceBias}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
            if (story.aiSources != null) ...[
              const SizedBox(height: 24),
              const _SectionHeader(title: 'AI Sources'),
              const SizedBox(height: 8),
              MarkdownBody(
                data: story.aiSources!,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(fontSize: 16),
                  listBullet: const TextStyle(fontSize: 16),
                ),
              ),
            ],
            if (story.overallMetrics != null) ...[
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Overall Metrics'),
              const SizedBox(height: 8),
              MarkdownBody(
                data: story.overallMetrics!,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(fontSize: 16),
                  listBullet: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({
    required this.label,
    required this.score,
    required this.icon,
    this.isWarning = false,
  });

  final String label;
  final int score;
  final IconData icon;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final color = isWarning
        ? (score > 50 ? Colors.red : Colors.orange)
        : (score > 70 ? Colors.green : Colors.orange);

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        '$label: $score',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      backgroundColor: color.withValues(alpha: 0.1),
    );
  }
}
