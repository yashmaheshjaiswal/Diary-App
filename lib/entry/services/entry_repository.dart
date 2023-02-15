import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:my_diary/entry/models/entry.dart';

const entriesBox = 'entries';

class EntryRepository {
  final Box _box = Hive.box(entriesBox);

  static Future<void> init() => Hive.openBox(entriesBox);

  static String storageKeyFromEntry(Entry entry) =>
      storageKey(userId: entry.userId, day: entry.day);

  static String storageKey({required String userId, required DateTime day}) =>
      "${userId}_${day.year}_${day.month}_${day.day}";

  Future<List<Entry>> findByDay(String userId, DateTime day) async {
    var rawEntries = _box.get(storageKey(userId: userId, day: day));
    return Entry.listFromJson(rawEntries != null ? jsonDecode(rawEntries) : []);
  }

  Future<void> remove(Entry entry) async {
    var entries = await findByDay(entry.userId, entry.day);

    entries.removeWhere((storedEntry) => storedEntry.id == entry.id);

    _box.put(storageKeyFromEntry(entry), jsonEncode(entries));
  }

  Future<void> persist(Entry entry) async {
    var entries = await findByDay(entry.userId, entry.day);
    try {
      var storedEntry =
          entries.firstWhere((storedEntry) => entry.id == storedEntry.id);
      storedEntry.title = entry.title;
      storedEntry.body = entry.body;
    } catch (e) {
      entries.add(entry);
    }

    _box.put(storageKeyFromEntry(entry), jsonEncode(entries));
  }
}
