import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:common_lib/models/app_theme.dart';
import 'package:common_lib/models/preferenced_element.dart';
import 'package:common_lib/providers/app_preferences.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:twitch_procastinator_puncher/widgets/info_tooltip.dart';
import 'package:twitch_procastinator_puncher/widgets/plus_or_minus.dart';

class FileSelectorTile extends StatelessWidget {
  const FileSelectorTile({
    super.key,
    required this.title,
    required this.file,
    required this.selectFileCallback,
    this.tooltipText,
    this.onSizeChanged,
  });

  final String title;
  final PreferencedFile file;
  final String? tooltipText;
  final Function(File?) selectFileCallback;
  final Function(PlusOrMinusSelection)? onSizeChanged;

  Future<void> _pickFile(context) async {
    final List<String> extensions = [];
    if (file.fileType == FileType.image) {
      extensions.addAll(['.jpg', '.png', '.jpeg']);
    } else if (file.fileType == FileType.sound) {
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
    selectFileCallback(File(path));
  }

  void _playSound() async {
    final player = AudioPlayer();
    await player.play(DeviceFileSource(file.filename!));
  }

  @override
  Widget build(BuildContext context) {
    final preferences = AppPreferences.of(context);
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
              Row(
                children: [
                  Text(title,
                      style: TextStyle(
                          color: ThemeColor().configurationText,
                          fontWeight: FontWeight.bold,
                          fontSize: ThemeSize.text(context))),
                  if (tooltipText != null) SizedBox(width: padding),
                  if (tooltipText != null) InfoTooltip(message: tooltipText),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: padding),
                child: Text(
                  file.filename ?? preferences.texts.filesNoneSelected,
                  style: TextStyle(
                      color: ThemeColor().configurationText,
                      fontSize: ThemeSize.smallText(context)),
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (file.fileType == FileType.image && file.filename != null)
              // Show a thumbnail
              SizedBox(
                  height: windowHeight * 0.045,
                  width: windowHeight * 0.045,
                  child: (file as PreferencedImageFile).image!),
            if (file.fileType == FileType.image &&
                file.filename != null &&
                onSizeChanged != null)
              // Show a thumbnail
              SizedBox(
                  width: windowHeight * 0.04,
                  child: PlusOrMinus(
                    onTap: onSizeChanged!,
                  )),
            if (file.fileType == FileType.sound && file.filename != null)
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
                  Icons.file_open,
                  color: Colors.amber,
                ),
              ),
            ),
            if (file.filename != null)
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
