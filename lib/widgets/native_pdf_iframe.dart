// Conditional export: web implementation when `dart:html` is available,
// otherwise a stub is used.
export 'native_pdf_iframe_stub.dart'
    if (dart.library.html) 'native_pdf_iframe_web.dart';
