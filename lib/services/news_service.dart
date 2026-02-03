import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_model.dart';

class NewsService {
  static const String _cacheKey = 'cached_news';
  static const Duration _cacheDuration = Duration(hours: 1);

  // FUENTES
  static final Map<String, String> _rssSources = {
    'ArchDaily': 'https://www.archdaily.mx/mx/rss',
    'El Universo': 'https://www.eluniverso.com/arc/outboundfeeds/rss/?outputType=xml',
  };

  static Future<List<NewsModel>> getNews({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cachedNews = await _getCachedNews();
      if (cachedNews.isNotEmpty) return cachedNews;
    }

    final allNews = <NewsModel>[];

    for (var entry in _rssSources.entries) {
      try {
        final news = await _fetchFromRss(entry.value, entry.key);
        allNews.addAll(news);
      } catch (e) {
        print('Error detallado en ${entry.key}: $e');
      }
    }

    allNews.sort((a, b) => (b.pubDate ?? DateTime(2000)).compareTo(a.pubDate ?? DateTime(2000)));
    await _saveToCache(allNews);
    return allNews;
  }

  static Future<List<NewsModel>> _fetchFromRss(String url, String sourceName) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          // User-Agent de navegador real para evitar bloqueos
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept': 'application/xml, text/xml, */*',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return [];

      final document = XmlDocument.parse(response.body);

      // Intentar buscar (RSS) o (Atom)
      final items = document.findAllElements('item').isNotEmpty
          ? document.findAllElements('item')
          : document.findAllElements('entry');

      return items.map((item) {
        final title = item.getElement('title')?.innerText ?? 'Sin título';
        final link = item.getElement('link')?.innerText ?? item.getElement('link')?.getAttribute('href');

        // Limpiar descripción de HTML
        String rawDescription = item.getElement('description')?.innerText ??
            item.getElement('content')?.innerText ??
            item.getElement('summary')?.innerText ?? '';

        final description = _cleanHtml(rawDescription);

        // Manejo de imagenes
        String imageUrl = '';

        //1. Buscar en media:content o media:thumbnail
        final media = item.findElements('media:content').firstOrNull ??
            item.findElements('media:thumbnail').firstOrNull;
        if (media != null) imageUrl = media.getAttribute('url') ?? '';

        // Buscar en enclosure
        if (imageUrl.isEmpty) {
          final enclosure = item.getElement('enclosure');
          if (enclosure != null) imageUrl = enclosure.getAttribute('url') ?? '';
        }

        // Extraer del HTML si no hay otra opción
        if (imageUrl.isEmpty && rawDescription.contains('<img')) {
          final imgMatch = RegExp(r'src="([^"]+)"').firstMatch(rawDescription);
          if (imgMatch != null) imageUrl = imgMatch.group(1)!;
        }

        if (imageUrl.isEmpty) {
          imageUrl = 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=800';
        }

        // Parseo de fechas
        DateTime? pubDate;
        final dateStr = item.getElement('pubDate')?.innerText ??
            item.getElement('published')?.innerText ??
            item.getElement('updated')?.innerText;

        if (dateStr != null) pubDate = _tryParseDate(dateStr);

        return NewsModel(
          title: title.trim(),
          description: description.length > 150 ? '${description.substring(0, 150)}...' : description,
          imageUrl: imageUrl,
          source: sourceName,
          link: link,
          pubDate: pubDate,
        );
      }).toList();
    } catch (e) {
      print('Error en $sourceName: $e');
      return [];
    }
  }

  static String _cleanHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>|&nbsp;'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static DateTime? _tryParseDate(String dateStr) {
    try {
      // Limpiar zonas horarias raras como "GMT+0000" o nombres de días
      return DateTime.parse(dateStr);
    } catch (_) {
      try {
        // Formato estándar RFC822 (RSS)
        return DateFormat("EEE, dd MMM yyyy HH:mm:ss Z", "en_US").parse(dateStr);
      } catch (_) {
        try {
          return DateFormat("yyyy-MM-dd'T'HH:mm:ss", "en_US").parse(dateStr);
        } catch (_) {
          return null;
        }
      }
    }
  }

  // Métodos de Cache (iguales a los tuyos)
  static Future<void> _saveToCache(List<NewsModel> news) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'news': news.map((n) => n.toMap()).toList(),
    };
    await prefs.setString(_cacheKey, jsonEncode(cacheData));
  }

  static Future<List<NewsModel>> _getCachedNews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      if (cachedJson != null) {
        final cacheData = jsonDecode(cachedJson);
        final timestamp = cacheData['timestamp'] as int;
        if (DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp)) < _cacheDuration) {
          return (cacheData['news'] as List).map((item) => NewsModel.fromMap(item)).toList();
        }
      }
    } catch (e) {}
    return [];
  }
}
