import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:french_stream_downloader/src/logic/models/uqvideo.dart';
import 'package:french_stream_downloader/src/logic/models/wishlist_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestionnaire centralisé de la wishlist utilisateur.
class WishlistManager {
  static const String _wishlistKey = 'landflix_wishlist_items';

  static WishlistManager? _instance;
  static WishlistManager get instance => _instance ??= WishlistManager._();

  WishlistManager._();

  final ValueNotifier<List<WishlistItem>> wishlistNotifier =
      ValueNotifier<List<WishlistItem>>(<WishlistItem>[]);

  List<WishlistItem> _items = [];

  Future<void> initialize() async {
    await _loadWishlist();
  }

  List<WishlistItem> get items => List.unmodifiable(_items);

  bool contains(String htmlUrl) {
    final id = WishlistItem.idFromUrl(htmlUrl);
    return _items.any((item) => item.id == id);
  }

  WishlistItem? getByUrl(String htmlUrl) {
    final id = WishlistItem.idFromUrl(htmlUrl);
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> toggle(Uqvideo video) async {
    final existing = getByUrl(video.htmlUrl);
    if (existing != null) {
      await remove(existing.id);
    } else {
      await add(WishlistItem.fromUqvideo(video));
    }
  }

  Future<void> add(WishlistItem item) async {
    _items.removeWhere((element) => element.id == item.id);
    _items.insert(0, item);
    await _persist();
  }

  Future<void> remove(String id) async {
    _items.removeWhere((element) => element.id == id);
    await _persist();
  }

  Future<void> clear() async {
    _items.clear();
    await _persist();
  }

  Future<void> _persist() async {
    wishlistNotifier.value = List.unmodifiable(_items);
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = jsonEncode(_items.map((e) => e.toJson()).toList());
      await prefs.setString(_wishlistKey, payload);
    } catch (e, stack) {
      dev.log(
        'Erreur lors de la sauvegarde de la wishlist',
        error: e,
        stackTrace: stack,
      );
    }
  }

  Future<void> _loadWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_wishlistKey);
      if (data == null) {
        _items = [];
        wishlistNotifier.value = const [];
        return;
      }
      final decoded = jsonDecode(data) as List<dynamic>;
      _items = decoded
          .map((entry) => WishlistItem.fromJson(entry as Map<String, dynamic>))
          .toList();
      wishlistNotifier.value = List.unmodifiable(_items);
    } catch (e, stack) {
      dev.log(
        'Erreur lors du chargement de la wishlist',
        error: e,
        stackTrace: stack,
      );
      _items = [];
      wishlistNotifier.value = const [];
    }
  }
}
