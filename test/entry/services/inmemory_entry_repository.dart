import 'dart:convert';

import 'package:my_diary/entry/models/entry.dart';
import 'package:my_diary/entry/services/entry_repository.dart';

class InMemoryEntryRepository implements EntryRepository {
  final Map<String, dynamic> _storage = {};

  InMemoryEntryRepository({Map<String, dynamic> data = const {}}) {
    _storage.addAll(data);
  }

  @override
  Future<List<Entry>> findByDay(String userId, DateTime day) async {
    var rawEntries =
        _storage[EntryRepository.storageKey(userId: userId, day: day)];
    return Entry.listFromJson(rawEntries != null ? jsonDecode(rawEntries) : []);
  }

  @override
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

    _storage[EntryRepository.storageKeyFromEntry(entry)] = jsonEncode(entries);
  }

  @override
  Future<void> remove(Entry entry) async {
    var entries = await findByDay(entry.userId, entry.day);

    entries.removeWhere((storedEntry) => storedEntry.id == entry.id);

    _storage[EntryRepository.storageKeyFromEntry(entry)] = jsonEncode(entries);
  }
}
