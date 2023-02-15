import 'package:flutter_test/flutter_test.dart';
import 'package:my_diary/entry/models/entry.dart';

const _id = 'id';
const _title = 'title';
const _userId = 'userId';
final _body = ['body'];
final _day = DateTime(2000);

void main() {
  group('Entry', () {
    test('transforms to Json', () {
      final entry = Entry(_id, _title, _body, _day, _userId);
      expect(entry.toJson(), {
        'id': _id,
        'title': _title,
        'body': _body,
        'day': _day.toString(),
        'userId': _userId
      });
    });

    test('loads from json', () {
      final entry = Entry.fromJson({
        'id': _id,
        'title': _title,
        'body': _body,
        'day': _day.toString(),
        'userId': _userId
      });

      expect(entry.toJson(), Entry(_id, _title, _body, _day, _userId).toJson());
    });
  });
}
