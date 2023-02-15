import 'package:flutter/material.dart';
import 'package:my_diary/components/text_editor/text_editor.dart';
import 'package:my_diary/components/text_editor/text_editor_toolbar.dart';
import 'package:my_diary/entry/models/entry.dart';
import 'package:my_diary/entry/services/entry_repository.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:intl/intl.dart';
import 'package:my_diary/user/models/user.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';

const saveEntryButtonKey = Key('saveButton');
const editEntryButtonKey = Key('editButton');
const titleFieldKey = Key('titleFieldKey');
const bodyFieldKey = Key('bodyFieldKey');
const dayFieldKey = Key('dayFieldKey');

class EntryPage extends StatefulWidget {
  final Function? callback;
  final Entry? entry;
  final bool readOnly;
  final DateTime? day;
  final EntryRepository? entryRepository;

  const EntryPage(
      {super.key,
      this.callback,
      this.entry,
      this.readOnly = false,
      this.day,
      this.entryRepository});

  @override
  EntryPageState createState() => EntryPageState();
}

class EntryPageState extends State<EntryPage> {
  final _formKey = GlobalKey<FormState>();
  bool _editorFocused = false;
  final _titleController = TextEditingController();
  final _dayController = TextEditingController();
  QuillController? _bodyController;
  final FocusNode _focusNode = FocusNode();
  late final _entryRepository = widget.entryRepository ?? EntryRepository();
  bool readOnly = false;
  String? _id;
  DateTime? _day;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title;
    }
    setState(() {
      _editorFocused = false;
      _id = widget.entry?.id;
      _day = widget.entry?.day ?? widget.day;
      readOnly = widget.readOnly;
      _dayController.text = formatDay();

      if (widget.entry != null) {
        _bodyController = QuillController(
            document: Document.fromJson(widget.entry!.body),
            selection: const TextSelection.collapsed(offset: 0));
      } else {
        _bodyController = QuillController.basic();
      }
    });
  }

  void showDayDatePicker() async {
    if (readOnly) {
      return;
    }

    var date = await showDatePicker(
        context: context,
        initialDate: _day!,
        firstDate: DateTime.utc(2020, 1, 1),
        lastDate: DateTime.now().add(const Duration(days: 365)));

    if (date != null) {
      setState(() {
        _day = date;
        _dayController.text = formatDay();
      });
    }
  }

  String formatDay() => DateFormat.yMMMd().format(_day!);

  Color getFocusColor() => _editorFocused
      ? Theme.of(context).primaryColor
      : Theme.of(context).hintColor;

  void saveEntry(User user) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    var entry = Entry(_id, _titleController.text,
        _bodyController!.document.toDelta().toJson(), _day!, user.id);
    await _entryRepository.persist(entry);

    if (widget.callback != null) {
      widget.callback!(entry);
    }

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
    var snackBar = SnackBar(
      content: Text(S.of(context).entrySaved),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5))),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    User user = context.read();

    if (_bodyController == null) {
      return Scaffold(
        appBar: AppBar(),
      );
    }

    TextEditor editor = TextEditor(
      key: bodyFieldKey,
      controller: _bodyController!,
      readOnly: readOnly,
      focusNode: _focusNode,
      showCursor: !readOnly,
    );

    editor.focusNode.addListener(() {
      setState(() {
        _editorFocused = editor.focusNode.hasFocus;
      });
    });

    void openEditEntry() {
      setState(() {
        readOnly = false;
      });
    }

    return Scaffold(
        appBar: AppBar(
            title: Text(widget.entry != null
                ? (readOnly ? S.of(context).entry : S.of(context).editEntry)
                : S.of(context).newEntry),
            actions: [
              readOnly
                  ? IconButton(
                      key: editEntryButtonKey,
                      icon: const Icon(Icons.edit),
                      onPressed: openEditEntry)
                  : IconButton(
                      key: saveEntryButtonKey,
                      icon: const Icon(Icons.check),
                      onPressed: () => saveEntry(user))
            ]),
        body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    key: titleFieldKey,
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      labelText: S.of(context).title,
                    ),
                    readOnly: readOnly,
                    controller: _titleController,
                    autofocus: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return S.of(context).emptyFieldError;
                      }
                      return null;
                    },
                    maxLength: 100,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    key: dayFieldKey,
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      labelText: S.of(context).date,
                    ),
                    onTap: showDayDatePicker,
                    controller: _dayController,
                    readOnly: true,
                  ),
                  const SizedBox(height: 20),
                  Text(S.of(context).body,
                      style: TextStyle(fontSize: 14, color: getFocusColor())),
                  const SizedBox(height: 10),
                  readOnly
                      ? const SizedBox(
                          height: 0,
                        )
                      : TextEditorToolbar.create(controller: _bodyController),
                  const SizedBox(height: 10),
                  Expanded(
                      child: Container(
                    decoration: BoxDecoration(
                        border: readOnly
                            ? null
                            : Border.all(width: 1.5, color: getFocusColor()),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5))),
                    padding: readOnly ? null : const EdgeInsets.all(10),
                    child: editor,
                  )),
                ],
              ),
            )));
  }
}
