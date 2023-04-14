import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FTP Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('FTP Demo'),
        ),
        body: Center(
          child: ElevatedButton(
            child: Text('Download file from FTP'),
            onPressed: () async {
              downloadFileFromFTP();
            },
          ),
        ),
      ),
    );
  }
}

// Find the correct local path
Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<Directory> createDownloadsDirectory() async {
  final path = await _localPath;
  final downloadsDir = Directory('$path/Download');
  if (!downloadsDir.existsSync()) {
    await downloadsDir.create(recursive: true);
  }
  return downloadsDir;
}

// Create a reference to the file location
Future<File> localFile(String fileName) async {
  final downloadsDir = await createDownloadsDirectory();
  File downloadedFile = File(downloadsDir.path + '$fileName');
  return downloadedFile;
}

// Download file
Future<File> downloadFileFromFTP() async {
  FTPConnect ftpConnect =
      FTPConnect('files.000webhost.com', user: 'azzamaddouri', pass: 'azza');
  try {
    String fileName = 'Chambres.zip';
    await ftpConnect.connect();
    print('Connected to FTP server');
    File _localFile = await localFile(fileName);

    print('Done');
    bool res = await ftpConnect.downloadFile(fileName, _localFile);
    print(_localFile);
    await ftpConnect.disconnect();
    print('Download successful: $res');
    return _localFile;
  } on SocketException catch (e) {
    print('SocketException: ${e.message}');
    return File("");
  } on FTPException catch (e) {
    print('FTPException: ${e.message}');
    return File("");
  } catch (e) {
    print('Error: ${e.toString()}');
    return File("");
  }
}

// Read data from the file
Future<String> readContent() async {
  try {
    File downloadedFile = await downloadFileFromFTP();
    final contents = await downloadedFile.readAsString();
    print(contents);
    return contents;
  } catch (e) {
    return '';
  }
}

// Write to the file
Future<File> writeContent() async {
  File downloadedFile = await downloadFileFromFTP();
  return downloadedFile.writeAsString("");
}

// Extract the Zip file
Future<void> extractFile() async {
  File downloadedFile = await downloadFileFromFTP();
  final bytes = await downloadedFile.readAsBytesSync();
  try {
    final archive = ZipDecoder().decodeBytes(bytes);
    for (var file in archive) {
      print('Done');
      final filename = file.name;
      print('Done!');
      final data = file.content as List<int>;

      await File(filename).writeAsBytes(data);
    }
  } catch (e) {
    print('Error extracting file: $e');
  }
}
