import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:app/main.dart';
import 'package:app/models/sounds.dart';
import 'package:app/util/edge_functions.dart';
import 'package:app/util/colors.dart';
import 'package:app/util/snackbar.dart';
import 'package:app/util/storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';

class EditSoundDialog extends StatefulWidget {
  const EditSoundDialog({super.key, required this.sound});

  final Sound sound;

  @override
  State<EditSoundDialog> createState() => _EditSoundDialogState();
}

class _EditSoundDialogState extends State<EditSoundDialog> {
  late final TextEditingController _name;
  late final TextEditingController _shortcut;
  Uint8List? _thumbnail;
  bool _loadingEdit = false;
  bool _loadingDelete = false;

  @override
  void initState() {
    _name = TextEditingController(text: widget.sound.name);
    _shortcut = TextEditingController(text: "Ctrl + Shift + 1");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (!_loadingEdit && !_loadingDelete) Navigator.pop(context);
          },
        ),
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Center(
              child: FadeInDown(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  decoration: const BoxDecoration(
                    color: BrandColors.grey,
                    borderRadius:
                        BorderRadius.all(Radius.circular(borderRadius)),
                  ),
                  padding: const EdgeInsets.all(32),
                  width: 550,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Edit Sound",
                          style: GoogleFonts.bebasNeue(
                            textStyle: const TextStyle(
                                color: BrandColors.white,
                                fontSize: 50,
                                height: 0.84),
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 174,
                            height: 174,
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: BrandColors.blackA,
                                      borderRadius:
                                          BorderRadius.circular(borderRadius),
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: _thumbnail == null
                                              ? NetworkImage(getThumbnail(
                                                      widget.sound))
                                                  as ImageProvider
                                              : MemoryImage(_thumbnail!))),
                                ),
                                TextButton(
                                  style: ButtonStyle(
                                      padding: MaterialStateProperty.all(
                                          const EdgeInsets.all(0)),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.transparent)),
                                  onPressed: () async {
                                    FilePickerResult? result = await FilePicker
                                        .platform
                                        .pickFiles(type: FileType.image);
                                    if (result == null) return;
                                    File file = File(result.files.single.path!);
                                    var data = await file.readAsBytes();
                                    setState(() => _thumbnail = data);
                                  },
                                  child: Container(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextField(
                                  controller: _name,
                                  onChanged: (_) => setState(() {}),
                                  decoration:
                                      const InputDecoration(labelText: "Name"),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                SizedBox(
                                  height: 48,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          enabled: false,
                                          controller: _shortcut,
                                          style: const TextStyle(
                                              color: BrandColors.white),
                                          decoration: const InputDecoration(
                                              labelText: "Shortcut",
                                              labelStyle: TextStyle(
                                                  color: BrandColors.white),
                                              disabledBorder:
                                                  OutlineInputBorder(
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                        borderRadius),
                                                    bottomLeft: Radius.circular(
                                                        borderRadius)),
                                                borderSide: BorderSide.none,
                                              )),
                                        ),
                                      ),
                                      AspectRatio(
                                        aspectRatio: 1,
                                        child: TextButton(
                                            onPressed: () async {},
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all(
                                                  const RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  borderRadius),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  borderRadius)))),
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      BrandColors.blackA),
                                              padding:
                                                  MaterialStateProperty.all(
                                                      const EdgeInsets.all(0)),
                                            ),
                                            child: const Icon(
                                              Icons.circle_sharp,
                                              size: 15,
                                            )),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                SizedBox(
                                  height: 48,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                            onPressed: (_name.value.text ==
                                                            widget.sound.name &&
                                                        _thumbnail == null) ||
                                                    _loadingEdit ||
                                                    _loadingDelete
                                                ? null
                                                : () async {
                                                    setState(() {
                                                      _loadingEdit = true;
                                                    });
                                                    try {
                                                      var res = await editSound(
                                                        id: widget.sound.id,
                                                        name: _name.value
                                                                    .text ==
                                                                widget
                                                                    .sound.name
                                                            ? null
                                                            : _name.value.text,
                                                        thumbnail: _thumbnail,
                                                      );
                                                      setState(() {
                                                        _loadingEdit = false;
                                                      });
                                                      if (context.mounted) {
                                                        if (res.status == 200) {
                                                          showSuccessSnackBar(
                                                              context,
                                                              'Successfully edited sound.');
                                                          Navigator.pop(
                                                              context);
                                                        } else {
                                                          showErrorSnackBar(
                                                              context,
                                                              'An error occurred when editing the sound.');
                                                        }
                                                      }
                                                    } catch (e) {
                                                      setState(() {
                                                        _loadingEdit = false;
                                                      });
                                                      if (context.mounted) {
                                                        showErrorSnackBar(
                                                            context,
                                                            'An error occurred when editing the sound.');
                                                      }
                                                    }
                                                  },
                                            style: ButtonStyle(
                                              padding:
                                                  MaterialStateProperty.all(
                                                      const EdgeInsets.all(0)),
                                            ),
                                            child: _loadingEdit
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(),
                                                  )
                                                : Text("Edit".toUpperCase(),
                                                    style: GoogleFonts.montserrat(
                                                        textStyle:
                                                            const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                letterSpacing:
                                                                    2)))),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: TextButton(
                                            onPressed: _loadingEdit
                                                ? null
                                                : () async {
                                                    setState(() {
                                                      _loadingDelete = true;
                                                    });
                                                    try {
                                                      var res = await supabase
                                                          .functions
                                                          .invoke(
                                                              'delete-sound',
                                                              body: {
                                                            'id':
                                                                widget.sound.id
                                                          });
                                                      setState(() {
                                                        _loadingDelete = false;
                                                      });
                                                      if (context.mounted) {
                                                        if (res.status == 200) {
                                                          showSuccessSnackBar(
                                                              context,
                                                              'Successfully deleted sound.');
                                                          Navigator.pop(
                                                              context);
                                                        } else {
                                                          showErrorSnackBar(
                                                              context,
                                                              'An error occurred when deleting the sound.');
                                                        }
                                                      }
                                                    } catch (e) {
                                                      setState(() {
                                                        _loadingDelete = false;
                                                      });
                                                      if (context.mounted) {
                                                        showErrorSnackBar(
                                                            context,
                                                            'An error occurred when deleting the sound.');
                                                      }
                                                    }
                                                  },
                                            style: ButtonStyle(
                                              padding:
                                                  MaterialStateProperty.all(
                                                      const EdgeInsets.all(0)),
                                            ),
                                            child: _loadingDelete
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(),
                                                  )
                                                : Text("Delete".toUpperCase(),
                                                    style: GoogleFonts.montserrat(
                                                        textStyle:
                                                            const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                letterSpacing:
                                                                    2)))),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
