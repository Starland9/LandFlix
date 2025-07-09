import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:french_stream_downloader/src/logic/cubits/uq/uq_cubit.dart';
import 'package:french_stream_downloader/src/logic/models/search_result.dart';
import 'package:french_stream_downloader/src/logic/repos/uq_repo.dart';
import 'package:french_stream_downloader/src/screens/result/components/uqvideo_widget.dart';

@RoutePage()
class UqvideosResultScreen extends StatelessWidget {
  const UqvideosResultScreen({super.key, required this.searchResult});

  final SearchResult searchResult;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          UqCubit(context.read<UqRepo>())
            ..getUqVideos(htmlUrl: searchResult.url),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300.0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  searchResult.title,
                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                ),
                background: Image.network(
                  searchResult.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            BlocBuilder<UqCubit, UqState>(
              builder: (context, state) {
                if (state is UqVideosLoaded) {
                  final uqvideos = state.results;
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Column(
                        children: [
                          UqvideoWidget(
                            key: Key(uqvideos[index].url),
                            uqvideo: uqvideos[index],
                          ),
                          SizedBox(height: 1),
                        ],
                      ),
                      childCount: uqvideos.length,
                    ),
                  );
                }
                if (state is UqError) {
                  return SliverFillRemaining(
                    child: Center(child: Text(state.message)),
                  );
                }
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
