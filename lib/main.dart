import 'dart:io';
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
              await readContent();
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

// Create a reference to the file location
Future<File> localFile(String fileName) async {
  final path = await _localPath;
  return File('$path/$fileName');
}

// Download file
Future<File> downloadFileFromFTP() async {
  FTPConnect ftpConnect = FTPConnect('files.000webhost.com',
      user: 'azzamaddouri', pass: '09948498');
  try {
    String fileName = 'ZPA.kml';
    await ftpConnect.connect();
    print('Connected to FTP server');
    File downloadedFile = await localFile(fileName);
    bool res = await ftpConnect.downloadFile(fileName, downloadedFile);
    await ftpConnect.disconnect();
    print('Download successful: $res');
    return downloadedFile;
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
