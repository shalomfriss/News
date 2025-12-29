import 'package:demo_news/categories/categories.dart';
import 'package:demo_news/stories/view/story_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:stories_repository/stories_repository.dart';

class StoriesView extends StatefulWidget {
  const StoriesView({super.key});

  @override
  State<StoriesView> createState() => _StoriesViewState();
}

class _StoriesViewState extends State<StoriesView> {
  final List<Story> _stories = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  int _offset = 0;
  final int _limit = 10;
  bool _hasMore = true;
  String? _currentCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedCategory =
          context.read<CategoriesBloc>().state.selectedCategory;
      _currentCategory = selectedCategory?.name;
      _loadStories();
    });
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
        category: _getCategoryFilter(),
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
    }
  }

  void _onCategoryChanged(String? newCategory) {
    if (_currentCategory != newCategory) {
      setState(() {
        _currentCategory = newCategory;
        _stories.clear();
        _offset = 0;
        _hasMore = true;
      });
      _loadStories();
    }
  }

  String? _getCategoryFilter() {
    // If category is 'top', don't filter by category (show all)
    if (_currentCategory == 'top') {
      return null;
    }
    return _currentCategory;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoriesBloc, CategoriesState>(
      listener: (context, state) {
        final selectedCategory = state.selectedCategory?.name;
        _onCategoryChanged(selectedCategory);
      },
      child: RefreshIndicator(
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
      physics: const ClampingScrollPhysics(),
      itemCount: _stories.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _stories.length) {
          if (_isLoading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _loadStories,
                child: const Text('Load More'),
              ),
            );
          }
        }

        final story = _stories[index];
        return _StoryCard(story: story);
      },
    );
  }
}

class _StoryCard extends StatefulWidget {
  const _StoryCard({required this.story});

  final Story story;

  @override
  State<_StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<_StoryCard> {
  final Map<String, bool> _expandedSections = {};

  bool _isSectionExpanded(String section) {
    return _expandedSections[section] ?? false;
  }

  void _toggleSection(String section) {
    setState(() {
      final isCurrentlyExpanded = _isSectionExpanded(section);
      _expandedSections.clear();
      if (!isCurrentlyExpanded) {
        _expandedSections[section] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => StoryDetailPage(story: widget.story),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            if (widget.story.summary != null) ...[
              Text(
                widget.story.summary!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                if (widget.story.accuracyScore != null) ...[
                  _ScoreChip(
                    label: 'Accuracy',
                    score: widget.story.accuracyScore!,
                    icon: Icons.fact_check,
                  ),
                  const SizedBox(width: 8),
                ],
                if (widget.story.propagandaScore != null) ...[
                  _ScoreChip(
                    label: 'Propaganda',
                    score: widget.story.propagandaScore!,
                    icon: Icons.warning,
                    isWarning: true,
                  ),
                ],
              ],
            ),
            if (widget.story.accuracyAssessment != null)
              _CollapsibleSection(
                title: 'Accuracy Assessment',
                content: widget.story.accuracyAssessment!,
                isExpanded: _isSectionExpanded('accuracy'),
                onToggle: () => _toggleSection('accuracy'),
              ),
            if (widget.story.propagandaIndicators != null)
              _CollapsibleSection(
                title: 'Propaganda Indicators',
                content: widget.story.propagandaIndicators!,
                isExpanded: _isSectionExpanded('propaganda'),
                onToggle: () => _toggleSection('propaganda'),
              ),
            if (widget.story.authorSources != null)
              _CollapsibleSection(
                title: 'Author Sources',
                content: widget.story.authorSources!,
                isExpanded: _isSectionExpanded('authorSources'),
                onToggle: () => _toggleSection('authorSources'),
                subtitle: widget.story.authorSourceBias != null
                    ? 'Bias: ${widget.story.authorSourceBias}'
                    : null,
              ),
            if (widget.story.aiSources != null)
              _CollapsibleSection(
                title: 'AI Sources',
                content: widget.story.aiSources!,
                isExpanded: _isSectionExpanded('aiSources'),
                onToggle: () => _toggleSection('aiSources'),
              ),
            if (widget.story.overallMetrics != null)
              _CollapsibleSection(
                title: 'Overall Metrics',
                content: widget.story.overallMetrics!,
                isExpanded: _isSectionExpanded('metrics'),
                onToggle: () => _toggleSection('metrics'),
              ),
          ],
        ),
      ),
    ),
    );
  }
}

class _CollapsibleSection extends StatelessWidget {
  const _CollapsibleSection({
    required this.title,
    required this.content,
    required this.isExpanded,
    required this.onToggle,
    this.subtitle,
  });

  final String title;
  final String content;
  final bool isExpanded;
  final VoidCallback onToggle;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        InkWell(
          onTap: onToggle,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.grey,
              ),
            ],
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 4),
          MarkdownBody(
            data: content,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(fontSize: 14),
              listBullet: const TextStyle(fontSize: 14),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ],
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
