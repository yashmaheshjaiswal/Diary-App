import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class TextEditor extends QuillEditor {
  TextEditor(
      {required super.controller,
      required super.focusNode,
      required super.readOnly,
      super.key,
      super.showCursor})
      : super(
            scrollable: true,
            scrollController: ScrollController(),
            autoFocus: false,
            expands: false,
            padding: EdgeInsets.zero);
}
