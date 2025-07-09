import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:french_stream_downloader/src/logic/cubits/uq/uq_cubit.dart';
import 'package:french_stream_downloader/src/logic/repos/uq_repo.dart';
import 'package:french_stream_downloader/src/screens/result/components/search_result_widget.dart';

@RoutePage()
class SearchResultScreen extends StatelessWidget {
  const SearchResultScreen({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UqCubit(context.read<UqRepo>())..search(query),
      child: Scaffold(
        appBar: AppBar(title: Text("Rechercher $query")),
        body: BlocBuilder<UqCubit, UqState>(
          builder: (context, state) {
            if (state is UqSearchLoaded) {
              final results = state.results;
              return GridView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) => SearchResultWidget(
                  key: Key(results[index].url),
                  searchResult: results[index],
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 9 / 16,
                ),
              );
            }
            if (state is UqError) {
              return Center(child: Text(state.message));
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
