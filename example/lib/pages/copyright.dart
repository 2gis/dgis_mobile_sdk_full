import 'dart:async';

import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'common.dart';

class CopyrightPage extends StatefulWidget {
  const CopyrightPage({required this.title, super.key});

  final String title;

  @override
  State<CopyrightPage> createState() => _CopyrightPageState();
}

enum _AlignmentLable {
  topLeft('TopLeft', Alignment.topLeft),
  topCenter('TopCenter', Alignment.topCenter),
  topRight('TopRight', Alignment.topRight),
  centerLeft('CenterLeft', Alignment.centerLeft),
  center('Center', Alignment.center),
  centerRight('CenterRight', Alignment.centerRight),
  bottomLeft('BottomLeft', Alignment.bottomLeft),
  bottomCenter('BottomCenter', Alignment.bottomCenter),
  bottomRight('BottomRight', Alignment.bottomRight);

  const _AlignmentLable(this.label, this.alignment);
  final String label;
  final Alignment alignment;
}

class _CopyrightPageState extends State<CopyrightPage> {
  final sdkContext = AppContainer().initializeSdk();
  late final sdk.MapWidgetController mapWidgetController =
      createMapWidgetController(sdkContext);
  final formKey = GlobalKey<FormState>();
  final alignmentController = TextEditingController();
  final leftInset = TextEditingController(text: '8.0');
  final topInset = TextEditingController(text: '8.0');
  final rightInset = TextEditingController(text: '8.0');
  final bottomInset = TextEditingController(text: '8.0');

  _AlignmentLable? selectedAlignment;
  bool mapInteractive = true;
  bool alertUriOpener = false;
  @override
  void initState() {
    super.initState();
    unawaited(initContext());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: <Widget>[
          sdk.MapWidget(
            sdkContext: sdkContext,
            controller: mapWidgetController,
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: CupertinoButton(
              onPressed: _show,
              child: const Icon(Icons.format_list_bulleted),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> initContext() async {
    await mapWidgetController.mapAsync;
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  void _show() {
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Copyright options'),
              content: Form(
                key: formKey,
                child: SizedBox(
                  height: 450,
                  width: 50,
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      CheckboxListTile(
                        value: mapInteractive,
                        onChanged: (value) {
                          setState(() {
                            mapInteractive = value ?? false;
                          });
                        },
                        title: const Text('Map iteractive'),
                      ),
                      CheckboxListTile(
                        value: alertUriOpener,
                        onChanged: (value) {
                          setState(() {
                            alertUriOpener = value ?? false;
                          });
                        },
                        title: const Text('Alert UriOpener'),
                      ),
                      const SizedBox(height: 10),
                      DropdownMenu<_AlignmentLable>(
                        initialSelection:
                            selectedAlignment ?? _AlignmentLable.bottomRight,
                        controller: alignmentController,
                        requestFocusOnTap: true,
                        label: const Text('Alignment'),
                        onSelected: (alignment) {
                          setState(() {
                            selectedAlignment = alignment;
                          });
                        },
                        dropdownMenuEntries: _AlignmentLable.values
                            .map<DropdownMenuEntry<_AlignmentLable>>(
                                (alignment) {
                          return DropdownMenuEntry<_AlignmentLable>(
                            value: alignment,
                            label: alignment.label,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'EdgeInsets:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ListTile(
                        title: TextFormField(
                          controller: leftInset,
                          decoration: const InputDecoration(
                            labelText: 'Left',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return null;
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid double';
                            }
                            return null;
                          },
                        ),
                      ),
                      ListTile(
                        title: TextFormField(
                          controller: topInset,
                          decoration: const InputDecoration(
                            labelText: 'Top',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return null;
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid double';
                            }
                            return null;
                          },
                        ),
                      ),
                      ListTile(
                        title: TextFormField(
                          controller: rightInset,
                          decoration: const InputDecoration(
                            labelText: 'Right',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return null;
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid double';
                            }
                            return null;
                          },
                        ),
                      ),
                      ListTile(
                        title: TextFormField(
                          controller: bottomInset,
                          decoration: const InputDecoration(
                            labelText: 'Bottom',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return null;
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid double';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final navigator = Navigator.of(context);
                      await _updateCopyrightSettings();
                      navigator.pop();
                    }
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateCopyrightSettings() async {
    final controller = mapWidgetController;

    final insets = EdgeInsets.fromLTRB(
      double.tryParse(leftInset.text) ?? 8.0,
      double.tryParse(topInset.text) ?? 8.0,
      double.tryParse(rightInset.text) ?? 8.0,
      double.tryParse(bottomInset.text) ?? 8.0,
    );
    final alignment = selectedAlignment?.alignment ?? Alignment.bottomRight;
    controller
      ..copyrightEdgeInsets = insets
      ..copyrightAlignment = alignment;
    if (alertUriOpener) {
      controller.setUriOpener(
        _showUriAlert,
      );
    }
    final map = await mapWidgetController.mapAsync;
    map.interactive = mapInteractive;
  }

  void _showUriAlert(String uri) {
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Uri alert'),
          content: Form(
            key: formKey,
            child: SizedBox(
              height: 50,
              width: 50,
              child: Text('Open uri $uri for information'),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
