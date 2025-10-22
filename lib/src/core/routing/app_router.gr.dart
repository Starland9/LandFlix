// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i9;
import 'package:flutter/foundation.dart' as _i10;
import 'package:french_stream_downloader/src/logic/models/search_result.dart'
    as _i11;
import 'package:french_stream_downloader/src/screens/downloads/downloads_screen.dart'
    as _i1;
import 'package:french_stream_downloader/src/screens/home/home_screen.dart'
    as _i2;
import 'package:french_stream_downloader/src/screens/main_wrapper/main_wrapper_screen.dart'
    as _i3;
import 'package:french_stream_downloader/src/screens/result/search_result_screen.dart'
    as _i4;
import 'package:french_stream_downloader/src/screens/result/uqvideos_result_screen.dart'
    as _i7;
import 'package:french_stream_downloader/src/screens/splash/splash_screen.dart'
    as _i5;
import 'package:french_stream_downloader/src/screens/update/update_required_screen.dart'
    as _i6;
import 'package:french_stream_downloader/src/screens/wishlist/wishlist_screen.dart'
    as _i8;

/// generated route for
/// [_i1.DownloadsScreen]
class DownloadsRoute extends _i9.PageRouteInfo<void> {
  const DownloadsRoute({List<_i9.PageRouteInfo>? children})
    : super(DownloadsRoute.name, initialChildren: children);

  static const String name = 'DownloadsRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i1.DownloadsScreen();
    },
  );
}

/// generated route for
/// [_i2.HomeScreen]
class HomeRoute extends _i9.PageRouteInfo<void> {
  const HomeRoute({List<_i9.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i2.HomeScreen();
    },
  );
}

/// generated route for
/// [_i3.MainWrapperScreen]
class MainWrapperRoute extends _i9.PageRouteInfo<void> {
  const MainWrapperRoute({List<_i9.PageRouteInfo>? children})
    : super(MainWrapperRoute.name, initialChildren: children);

  static const String name = 'MainWrapperRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i3.MainWrapperScreen();
    },
  );
}

/// generated route for
/// [_i4.SearchResultScreen]
class SearchResultRoute extends _i9.PageRouteInfo<SearchResultRouteArgs> {
  SearchResultRoute({
    _i10.Key? key,
    required String query,
    List<_i9.PageRouteInfo>? children,
  }) : super(
         SearchResultRoute.name,
         args: SearchResultRouteArgs(key: key, query: query),
         initialChildren: children,
       );

  static const String name = 'SearchResultRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SearchResultRouteArgs>();
      return _i4.SearchResultScreen(key: args.key, query: args.query);
    },
  );
}

class SearchResultRouteArgs {
  const SearchResultRouteArgs({this.key, required this.query});

  final _i10.Key? key;

  final String query;

  @override
  String toString() {
    return 'SearchResultRouteArgs{key: $key, query: $query}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SearchResultRouteArgs) return false;
    return key == other.key && query == other.query;
  }

  @override
  int get hashCode => key.hashCode ^ query.hashCode;
}

/// generated route for
/// [_i5.SplashScreen]
class SplashRoute extends _i9.PageRouteInfo<void> {
  const SplashRoute({List<_i9.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i5.SplashScreen();
    },
  );
}

/// generated route for
/// [_i6.UpdateRequiredScreen]
class UpdateRequiredRoute extends _i9.PageRouteInfo<UpdateRequiredRouteArgs> {
  UpdateRequiredRoute({
    _i10.Key? key,
    required String latestVersion,
    List<_i9.PageRouteInfo>? children,
  }) : super(
         UpdateRequiredRoute.name,
         args: UpdateRequiredRouteArgs(key: key, latestVersion: latestVersion),
         initialChildren: children,
       );

  static const String name = 'UpdateRequiredRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UpdateRequiredRouteArgs>();
      return _i6.UpdateRequiredScreen(
        key: args.key,
        latestVersion: args.latestVersion,
      );
    },
  );
}

class UpdateRequiredRouteArgs {
  const UpdateRequiredRouteArgs({this.key, required this.latestVersion});

  final _i10.Key? key;

  final String latestVersion;

  @override
  String toString() {
    return 'UpdateRequiredRouteArgs{key: $key, latestVersion: $latestVersion}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UpdateRequiredRouteArgs) return false;
    return key == other.key && latestVersion == other.latestVersion;
  }

  @override
  int get hashCode => key.hashCode ^ latestVersion.hashCode;
}

/// generated route for
/// [_i7.UqvideosResultScreen]
class UqvideosResultRoute extends _i9.PageRouteInfo<UqvideosResultRouteArgs> {
  UqvideosResultRoute({
    _i10.Key? key,
    required _i11.SearchResult searchResult,
    List<_i9.PageRouteInfo>? children,
  }) : super(
         UqvideosResultRoute.name,
         args: UqvideosResultRouteArgs(key: key, searchResult: searchResult),
         initialChildren: children,
       );

  static const String name = 'UqvideosResultRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UqvideosResultRouteArgs>();
      return _i7.UqvideosResultScreen(
        key: args.key,
        searchResult: args.searchResult,
      );
    },
  );
}

class UqvideosResultRouteArgs {
  const UqvideosResultRouteArgs({this.key, required this.searchResult});

  final _i10.Key? key;

  final _i11.SearchResult searchResult;

  @override
  String toString() {
    return 'UqvideosResultRouteArgs{key: $key, searchResult: $searchResult}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UqvideosResultRouteArgs) return false;
    return key == other.key && searchResult == other.searchResult;
  }

  @override
  int get hashCode => key.hashCode ^ searchResult.hashCode;
}

/// generated route for
/// [_i8.WishlistScreen]
class WishlistRoute extends _i9.PageRouteInfo<void> {
  const WishlistRoute({List<_i9.PageRouteInfo>? children})
    : super(WishlistRoute.name, initialChildren: children);

  static const String name = 'WishlistRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i8.WishlistScreen();
    },
  );
}
