import 'package:flutter/material.dart';

import '../add_objects.dart';

class MarkerOptionsDialog extends StatefulWidget {
  final String initialUserData;
  final String initialZIndex;
  final String initialText;
  final MarkerType initialMarkerType;
  final double initialMarkerWidth;
  final String initialMarkerElevation;
  final GlobalKey<FormState> formKey;
  final void Function(
    String userData,
    String zIndex,
    String text,
    MarkerType markerType,
    double markerWidth,
    String markerElevation,
  ) onAddMarker;

  const MarkerOptionsDialog({
    required this.initialUserData,
    required this.initialZIndex,
    required this.initialText,
    required this.initialMarkerType,
    required this.initialMarkerWidth,
    required this.initialMarkerElevation,
    required this.formKey,
    required this.onAddMarker,
    super.key,
  });

  @override
  MarkerOptionsDialogState createState() => MarkerOptionsDialogState();
}

class MarkerOptionsDialogState extends State<MarkerOptionsDialog> {
  late TextEditingController userDataController;
  late TextEditingController zIndexController;
  late TextEditingController textController;
  late MarkerType markerType;
  late double markerWidth;
  late TextEditingController markerElevation;

  @override
  void initState() {
    super.initState();
    userDataController = TextEditingController(text: widget.initialUserData);
    zIndexController = TextEditingController(text: widget.initialZIndex);
    textController = TextEditingController(text: widget.initialText);
    markerType = widget.initialMarkerType;
    markerWidth = widget.initialMarkerWidth;
    markerElevation =
        TextEditingController(text: widget.initialMarkerElevation);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Marker options'),
      content: Form(
        key: widget.formKey,
        child: SizedBox(
          height: 350,
          width: 50,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              const Text('Marker type:'),
              Column(
                children: <Widget>[
                  RadioListTile<MarkerType>(
                    title: const Text('Scooter'),
                    value: MarkerType.scooterPng,
                    groupValue: markerType,
                    onChanged: (value) => setState(() => markerType = value!),
                  ),
                  RadioListTile<MarkerType>(
                    title: const Text('Bridge'),
                    value: MarkerType.bridgeSvg,
                    groupValue: markerType,
                    onChanged: (value) => setState(() => markerType = value!),
                  ),
                  RadioListTile<MarkerType>(
                    title: const Text('Bat'),
                    value: MarkerType.batLottie,
                    groupValue: markerType,
                    onChanged: (value) => setState(() => markerType = value!),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
              ListTile(
                title: TextField(
                  controller: userDataController,
                  decoration: const InputDecoration(
                    labelText: 'UserData',
                  ),
                ),
              ),
              ListTile(
                title: TextFormField(
                  controller: zIndexController,
                  decoration: const InputDecoration(
                    labelText: 'zIndex',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value for zIndex';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid integer';
                    }
                    return null;
                  },
                ),
              ),
              ListTile(
                title: TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    labelText: 'Text',
                  ),
                ),
              ),
              const Text('Marker width:'),
              Column(
                children: <Widget>[
                  RadioListTile<double>(
                    title: const Text('Thin'),
                    value: 30,
                    groupValue: markerWidth,
                    onChanged: (value) => setState(() => markerWidth = value!),
                  ),
                  RadioListTile<double>(
                    title: const Text('Medium'),
                    value: 45,
                    groupValue: markerWidth,
                    onChanged: (value) => setState(() => markerWidth = value!),
                  ),
                  RadioListTile<double>(
                    title: const Text('Thick'),
                    value: 60,
                    groupValue: markerWidth,
                    onChanged: (value) => setState(() => markerWidth = value!),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
              ListTile(
                title: TextFormField(
                  controller: markerElevation,
                  decoration: const InputDecoration(
                    labelText: 'Marker Elevation',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value for Elevation';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid integer';
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
          onPressed: () {
            if (widget.formKey.currentState!.validate()) {
              widget.onAddMarker(
                userDataController.text,
                zIndexController.text,
                textController.text,
                markerType,
                markerWidth,
                markerElevation.text,
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add Object'),
        ),
      ],
    );
  }
}
