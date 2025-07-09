import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/core/routing/app_router.gr.dart';
import 'package:french_stream_downloader/src/logic/models/search_result.dart';

class SearchResultWidget extends StatelessWidget {
  const SearchResultWidget({super.key, required this.searchResult});

  final SearchResult searchResult;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          context.pushRoute(UqvideosResultRoute(searchResult: searchResult)),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 8,
            children: [
              Expanded(child: Image.network(searchResult.imageUrl)),
              Text(
                searchResult.title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
