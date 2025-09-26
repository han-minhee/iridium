typedef ReaderHostAction = void Function(String text);

/// Host-app callbacks that can be assigned by applications integrating the reader.
/// These are intentionally declared in the reader package so the app doesn't
/// need to be imported by the package.
class ReaderHostCallbacks {
  static ReaderHostAction? onTranslate;
  static ReaderHostAction? onExtraInfo;
  static ReaderHostAction? onTts;
}



