import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stories_repository/stories_repository.dart';

class StoriesPage extends StatefulWidget {
  const StoriesPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (_) => const StoriesPage());
  }

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
  final List<Story> _stories = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  int _offset = 0;
  final int _limit = 10;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final storiesRepository = context.read<StoriesRepository>();
      final response = await storiesRepository.getStories(
        limit: _limit,
        offset: _offset,
      );

      setState(() {
        _stories.addAll(response.stories);
        _offset += response.stories.length;
        _hasMore = response.hasMore;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
      print('Error in _loadStories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fact-Checked Stories'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _stories.clear();
            _offset = 0;
            _hasMore = true;
          });
          await _loadStories();
        },
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_hasError && _stories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Failed to load stories'),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStories,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_stories.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_stories.isEmpty) {
      return const Center(
        child: Text('No stories available'),
      );
    }

    return ListView.builder(
      itemCount: _stories.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _stories.length) {
          // Load more indicator
          if (_isLoading) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          } else {
            // Load more button
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _loadStories,
                child: const Text('Load More'),
              ),
            );
          }
        }

        final story = _stories[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary
                if (story.summary != null) ...[
                  Text(
                    story.summary!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Scores Row
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

                // Accuracy Assessment
                if (story.accuracyAssessment != null) ...[
                  const SizedBox(height: 12),
                  const _SectionHeader(title: 'Accuracy Assessment'),
                  const SizedBox(height: 4),
                  Text(
                    story.accuracyAssessment!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],

                // Propaganda Indicators
                if (story.propagandaIndicators != null) ...[
                  const SizedBox(height: 12),
                  const _SectionHeader(title: 'Propaganda Indicators'),
                  const SizedBox(height: 4),
                  Text(
                    story.propagandaIndicators!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],

                // Sources
                if (story.authorSources != null) ...[
                  const SizedBox(height: 12),
                  const _SectionHeader(title: 'Author Sources'),
                  const SizedBox(height: 4),
                  Text(
                    story.authorSources!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],

                // Source Bias
                if (story.authorSourceBias != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Bias: ${story.authorSourceBias}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],

                // AI Sources
                if (story.aiSources != null) ...[
                  const SizedBox(height: 12),
                  const _SectionHeader(title: 'AI Sources'),
                  const SizedBox(height: 4),
                  Text(
                    story.aiSources!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],

                // Overall Metrics
                if (story.overallMetrics != null) ...[
                  const SizedBox(height: 12),
                  const _SectionHeader(title: 'Overall Metrics'),
                  const SizedBox(height: 4),
                  Text(
                    story.overallMetrics!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
        );
      },
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
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
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
