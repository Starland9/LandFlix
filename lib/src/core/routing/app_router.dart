import 'package:auto_route/auto_route.dart';
import 'package:french_stream_downloader/src/core/routing/app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.cupertino();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: MainWrapperRoute.page),
    AutoRoute(page: HomeRoute.page),
    AutoRoute(page: WishlistRoute.page),
    AutoRoute(page: SearchResultRoute.page),
    AutoRoute(page: UqvideosResultRoute.page),
    AutoRoute(page: DownloadsRoute.page),
    AutoRoute(page: BackgroundDownloadsRoute.page),
  ];
}
