import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:twitch_pomorodo_timer/models/app_theme.dart';
import 'package:twitch_pomorodo_timer/providers/app_preferences.dart';

class FileSelectorTile extends StatelessWidget {
  const FileSelectorTile(
      {super.key,
      required this.title,
      required this.path,
      required this.selectFileCallback,
      this.isImage = false,
      this.isSound = false});

  final String title;
  final String? path;
  final bool isImage;
  final bool isSound;
  final Function(String?) selectFileCallback;

  Future<void> _pickFile(context) async {
    final List<String> extensions = [];
    if (isImage) {
      extensions.addAll(['.jpg', '.png', '.jpeg']);
    }
    if (isSound) {
      extensions.addAll(['.mp3', '.wav']);
    }

    final appPreferences = AppPreferences.of(context, listen: false);
    final path = await FilesystemPicker.open(
      title: 'Open file',
      context: context,
      directory: appPreferences.lastVisitedDirectory,
      rootDirectory: Directory(rootPath),
      rootName: rootPath,
      fsType: FilesystemType.file,
      allowedExtensions: extensions,
      fileTileSelectMode: FileTileSelectMode.wholeTile,
    );

    if (path == null) return;
    selectFileCallback(path);
  }

  void _playSound() async {
    final player = AudioPlayer();
    await player.play(DeviceFileSource(path!));
  }

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;
    final padding = ThemePadding.normal(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: windowHeight * 0.25,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      color: ThemeColor().configurationText,
                      fontWeight: FontWeight.bold)),
              Padding(
                padding: EdgeInsets.only(left: padding),
                child: Text(
                  path != null ? basename(path!) : 'None selected',
                  style: TextStyle(color: ThemeColor().configurationText),
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isImage && path != null)
              // Show a thumbnail
              SizedBox(
                  height: windowHeight * 0.045,
                  width: windowHeight * 0.045,
                  child: Image.file(File(path!))),
            if (isSound && path != null)
              SizedBox(
                  height: windowHeight * 0.045,
                  width: windowHeight * 0.045,
                  child: InkWell(
                    onTap: _playSound,
                    child: const Icon(
                      Icons.play_circle_outline,
                      color: Colors.green,
                    ),
                  )),
            SizedBox(
              height: windowHeight * 0.045,
              width: windowHeight * 0.045,
              child: InkWell(
                onTap: () => _pickFile(context),
                child: const Icon(
                  Icons.file_download,
                  color: Colors.amber,
                ),
              ),
            ),
            SizedBox(
              height: windowHeight * 0.045,
              width: windowHeight * 0.045,
              child: InkWell(
                onTap: () => selectFileCallback(null),
                child: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
