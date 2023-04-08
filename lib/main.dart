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
              await downloadFileFromFTP();
            },
          ),
        ),
      ),
    );
  }
}

Future<void> downloadFileFromFTP() async {
  FTPConnect ftpConnect = FTPConnect('files.000webhost.com',
      user: 'azzamaddouri', pass: '09948498');
  try {
    String fileName = 'ZPA.kml';
    await ftpConnect.connect();
    print('Connected to FTP server');
    Directory downloadsDirectory = await getApplicationDocumentsDirectory();
    String downloadsPath = downloadsDirectory.path;
    File downloadedFile = File('$downloadsPath/$fileName');
    bool res = await ftpConnect.downloadFile(
        fileName, /* The file I'm gonna write in */ downloadedFile);
    await ftpConnect.disconnect();
    print('Download successful: $res');
  } on SocketException catch (e) {
    print('SocketException: ${e.message}');
  } on FTPException catch (e) {
    print('FTPException: ${e.message}');
  } catch (e) {
    print('Error: ${e.toString()}');
  }
}
