import 'dart:convert';

import 'package:file_picker/file_picker.dart' as fp;
import 'package:file_sender/file_sender.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;
import 'package:web_socket_client/web_socket_client.dart' as ws;

class FilePickerInterface {
  // Prepare the singleton
  FilePickerInterface._();
  static final FilePickerInterface _instance = FilePickerInterface._();
  static FilePickerInterface get instance => _instance;

  final int _port = 3004;
  bool _hasTestedConnexionToFileSender = false;
  bool _hasConnexionToFileSender = false;

  Future<Uint8List?> pickFile(context) async {
    // Test if the port 3004 is listened to. If so, use the file_sender plugin,
    // otherwise use the file_picker plugin
    if (!_hasTestedConnexionToFileSender) await _testConnexion();

    if (_hasConnexionToFileSender) {
      return await showFileSenderPickDialog(context, port: _port);
    } else {
      return (await fp.FilePicker.platform.pickFiles())?.files[0].bytes;
    }
  }

  Future<void> _testConnexion() async {
    final socket = ws.WebSocket(Uri.parse('ws://localhost:$_port'));

    // Test the connexion to file sender for 1 second. If none is established,
    // use the file_picker plugin
    socket.messages.listen((event) => _hasConnexionToFileSender = true);
    await Future.delayed(const Duration(seconds: 1), () => socket.close());

    _hasTestedConnexionToFileSender = true;
  }

  Future<void> saveFile(context,
      {required String data, required String filename}) async {
    // Test if the port 3004 is listened to. If so, use the file_sender plugin,
    // otherwise use the file_picker plugin
    if (!_hasTestedConnexionToFileSender) await _testConnexion();

    if (_hasConnexionToFileSender) {
      await showFileSenderSaveDialog(context, data: data, port: _port);
    } else {
      if (!kIsWeb) {
        throw 'saveFile is currently only implemented for web-based interface';
      }

      final bytes = utf8.encode(data);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = filename;
      html.document.body!.children.add(anchor);

      // download
      anchor.click();

      // cleanup
      html.document.body!.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    }
  }
}
