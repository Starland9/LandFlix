import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:french_stream_downloader/src/core/themes/colors.dart';
import 'package:french_stream_downloader/src/logic/cubits/uq/uq_cubit.dart';
import 'package:french_stream_downloader/src/logic/models/search_result.dart';
import 'package:french_stream_downloader/src/logic/repos/uq_repo.dart';
import 'package:french_stream_downloader/src/screens/result/components/empty_state_widget.dart';
import 'package:french_stream_downloader/src/screens/result/components/error_state_widget.dart';
import 'package:french_stream_downloader/src/screens/result/components/loading_state_widget.dart';
import 'package:french_stream_downloader/src/screens/result/components/uqvideo_widget.dart';

@RoutePage()
class UqvideosResultScreen extends StatefulWidget {
  const UqvideosResultScreen({super.key, required this.searchResult});

  final SearchResult searchResult;

  @override
  State<UqvideosResultScreen> createState() => _UqvideosResultScreenState();
}

class _UqvideosResultScreenState extends State<UqvideosResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          UqCubit(context.read<UqRepo>())
            ..getUqVideos(htmlUrl: widget.searchResult.url),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.darkBackground,
                Color(0xFF1A0A2E),
                AppColors.darkBackground,
              ],
            ),
          ),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header moderne avec image hero
              SliverAppBar(
                expandedHeight: 280.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.searchResult.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image de fond
                      Image.network(
                        widget.searchResult.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: const BoxDecoration(
                              gradient: AppColors.cardGradient,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.movie_rounded,
                                size: 64,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          );
                        },
                      ),

                      // Overlay gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),

                      // Info overlay
                      Positioned(
                        bottom: 80,
                        left: 16,
                        right: 16,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.play_circle_fill_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Vidéos disponibles",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Contenu principal
              BlocBuilder<UqCubit, UqState>(
                builder: (context, state) {
                  if (state is UqVideosLoaded) {
                    final uqvideos = state.results;

                    if (uqvideos.isEmpty) {
                      return const SliverFillRemaining(
                        child: EmptyStateWidget(),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.only(top: 16, bottom: 32),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position:
                                  Tween<Offset>(
                                    begin: Offset(0, 0.3 + (index * 0.1)),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: _fadeController,
                                      curve: Interval(
                                        (index * 0.1).clamp(0.0, 0.8),
                                        1.0,
                                        curve: Curves.easeOutCubic,
                                      ),
                                    ),
                                  ),
                              child: UqvideoWidget(
                                key: Key(uqvideos[index].url),
                                uqvideo: uqvideos[index],
                              ),
                            ),
                          );
                        }, childCount: uqvideos.length),
                      ),
                    );
                  }

                  if (state is UqError) {
                    return SliverFillRemaining(
                      child: ErrorStateWidget(
                        message: state.message,
                        onRetry: () {
                          context.read<UqCubit>().getUqVideos(
                            htmlUrl: widget.searchResult.url,
                          );
                        },
                      ),
                    );
                  }

                  return const SliverFillRemaining(child: LoadingStateWidget());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
