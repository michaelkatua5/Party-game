import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../data/repositories/word_stats_repository.dart';
import '../../../domain/models/word_stats.dart';
import '../../../domain/models/word.dart';
import '../../../domain/models/category.dart';

final adminStatsProvider = FutureProvider.autoDispose((ref) async {
  final statsRepo = ref.watch(wordStatsRepositoryProvider);
  final wordRepo = ref.watch(wordRepositoryProvider);
  final categoryRepo = ref.watch(categoryRepositoryProvider);

  final stats = await statsRepo.getAllStats();
  final words = await wordRepo.getAllWords();
  final categories = await categoryRepo.getCategories();

  return AdminData(stats: stats, words: words, categories: categories);
});

class AdminData {
  final List<WordStats> stats;
  final List<GameWord> words;
  final List<GameCategory> categories;

  AdminData({required this.stats, required this.words, required this.categories});
}

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin & Analytics'),
      ),
      body: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) {
          final statsMap = {for (var s in data.stats) s.wordId: s};
          
          final needsReview = data.stats.where((s) => s.status == 'needs_review').toList();
          final easyCount = data.stats.where((s) => s.difficultyLevel == 'easy').length;
          final medCount = data.stats.where((s) => s.difficultyLevel == 'medium').length;
          final hardCount = data.stats.where((s) => s.difficultyLevel == 'hard').length;
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Overview', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatCard('Total Words', '${data.words.length}'),
                  _StatCard('With Data', '${data.stats.length}'),
                  _StatCard('Needs Review', '${needsReview.length}', color: Colors.red),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatCard('Easy', '$easyCount', color: Colors.green),
                  _StatCard('Medium', '$medCount', color: Colors.orange),
                  _StatCard('Hard', '$hardCount', color: Colors.red),
                ],
              ),
              const SizedBox(height: 24),
              Text('Word Statistics', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Word')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Difficulty')),
                    DataColumn(label: Text('Score')),
                    DataColumn(label: Text('Shown')),
                    DataColumn(label: Text('Guessed')),
                    DataColumn(label: Text('Skipped')),
                    DataColumn(label: Text('Failed')),
                    DataColumn(label: Text('Avg Time')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: data.words.map((word) {
                    final stat = statsMap[word.id] ?? WordStats(wordId: word.id);
                    return DataRow(
                      cells: [
                        DataCell(Text(word.word)),
                        DataCell(Text(word.categoryId)),
                        DataCell(Text(stat.difficultyLevel.toUpperCase())),
                        DataCell(Text('${stat.difficultyScore}')),
                        DataCell(Text('${stat.timesShown}')),
                        DataCell(Text('${stat.timesGuessed}')),
                        DataCell(Text('${stat.timesSkipped}')),
                        DataCell(Text('${stat.timesFailed}')),
                        DataCell(Text('${stat.averageTimeSeconds.toStringAsFixed(1)}s')),
                        DataCell(Text(stat.status)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? color;

  const _StatCard(this.title, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
