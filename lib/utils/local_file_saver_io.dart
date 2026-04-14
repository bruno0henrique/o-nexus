import 'dart:io';

Future<String> saveBytesToClientFolder({
  required List<int> bytes,
  required String directoryPath,
  required String fileName,
}) async {
  final dir = Directory(directoryPath);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  final fullPath = '${dir.path}${Platform.pathSeparator}$fileName';
  final file = File(fullPath);
  await file.writeAsBytes(bytes, flush: true);
  return fullPath;
}
