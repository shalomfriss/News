import 'package:demo_news/l10n/l10n.dart';
import 'package:demo_news/search/search.dart';
import 'package:demo_news/stories/view/story_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_repository/news_repository.dart';
import 'package:stories_repository/stories_repository.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchBloc>(
      create: (context) => SearchBloc(
        newsRepository: context.read<NewsRepository>(),
        storiesRepository: context.read<StoriesRepository>(),
      )..add(const SearchTermChanged()),
      child: const SearchView(),
    );
  }
}

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(
      () => context
          .read<SearchBloc>()
          .add(SearchTermChanged(searchTerm: _controller.text)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SearchBloc, SearchState>(
      listener: (context, state) {
        if (state.status == SearchStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(context.l10n.searchErrorMessage)),
            );
        }
      },
      builder: (context, state) {
        return CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  SearchTextField(
                    key: const Key('searchPage_searchTextField'),
                    controller: _controller,
                  ),
                  SearchHeadlineText(
                    headerText: state.searchType == SearchType.popular
                        ? 'Recent Stories'
                        : 'Search Results',
                  ),
                ],
              ),
            ),
            if (state.status == SearchStatus.loading)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            else if (state.stories.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      state.searchType == SearchType.relevant
                          ? 'No stories found'
                          : 'No stories available',
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final story = state.stories[index];
                    return _SearchStoryCard(story: story);
                  },
                  childCount: state.stories.length,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SearchStoryCard extends StatelessWidget {
  const _SearchStoryCard({required this.story});

  final Story story;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => StoryDetailPage(story: story),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (story.summary != null)
                Text(
                  story.summary!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (story.category != null)
                    Chip(
                      label: Text(
                        story.category!.toUpperCase(),
                        style: const TextStyle(fontSize: 10),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  const SizedBox(width: 8),
                  if (story.accuracyScore != null)
                    Chip(
                      avatar: Icon(
                        Icons.fact_check,
                        size: 14,
                        color: story.accuracyScore! > 70
                            ? Colors.green
                            : Colors.orange,
                      ),
                      label: Text(
                        'Accuracy: ${story.accuracyScore}',
                        style: const TextStyle(fontSize: 10),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
