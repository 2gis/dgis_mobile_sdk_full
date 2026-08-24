import 'package:flutter/material.dart';

class PolygonOptionsDialog extends StatefulWidget {
  final String initialPointCount;
  final String initialUserData;
  final String initialZIndex;
  final int initialSelectedColor;
  final int initialSelectedStrokeColor;
  final double initialStrokeWidth;
  final GlobalKey<FormState> formKey;
  final void Function(
    String pointCount,
    String userData,
    String zIndex,
    int color,
    int strokeColor,
    double strokeWidth,
  ) onAddPolygon;

  const PolygonOptionsDialog({
    required this.initialPointCount,
    required this.initialUserData,
    required this.initialZIndex,
    required this.initialSelectedColor,
    required this.initialSelectedStrokeColor,
    required this.initialStrokeWidth,
    required this.formKey,
    required this.onAddPolygon,
    super.key,
  });

  @override
  PolygonOptionsDialogState createState() => PolygonOptionsDialogState();
}

class PolygonOptionsDialogState extends State<PolygonOptionsDialog> {
  late TextEditingController pointCountController;
  late TextEditingController userDataController;
  late TextEditingController zIndexController;
  late int selectedColor;
  late int selectedStrokeColor;
  late double strokeWidth;

  @override
  void initState() {
    super.initState();
    pointCountController =
        TextEditingController(text: widget.initialPointCount);
    userDataController = TextEditingController(text: widget.initialUserData);
    zIndexController = TextEditingController(text: widget.initialZIndex);
    selectedColor = widget.initialSelectedColor;
    selectedStrokeColor = widget.initialSelectedStrokeColor;
    strokeWidth = widget.initialStrokeWidth;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Polygon options'),
      content: Form(
        key: widget.formKey,
        child: SizedBox(
          height: 350,
          width: 50,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              ListTile(
                title: TextFormField(
                  controller: pointCountController,
                  decoration: const InputDecoration(
                    labelText: 'Point count',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value for point count';
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
              const SizedBox(height: 10),
              const Text('Color:'),
              RadioGroup<int>(
                groupValue: selectedColor,
                onChanged: (value) => setState(() => selectedColor = value!),
                child: Column(
                  children: <Widget>[
                    RadioListTile<int>(
                      title: const Text('Black'),
                      value: Colors.black.toARGB32(),
                    ),
                    RadioListTile<int>(
                      title: const Text('Red'),
                      value: Colors.red.toARGB32(),
                    ),
                    RadioListTile<int>(
                      title: const Text('Blue'),
                      value: Colors.blue.toARGB32(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text('Stroke Color:'),
              RadioGroup<int>(
                groupValue: selectedStrokeColor,
                onChanged: (value) =>
                    setState(() => selectedStrokeColor = value!),
                child: Column(
                  children: <Widget>[
                    RadioListTile<int>(
                      title: const Text('Black'),
                      value: Colors.black.toARGB32(),
                    ),
                    RadioListTile<int>(
                      title: const Text('Red'),
                      value: Colors.red.toARGB32(),
                    ),
                    RadioListTile<int>(
                      title: const Text('Blue'),
                      value: Colors.blue.toARGB32(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text('Width:'),
              RadioGroup<double>(
                groupValue: strokeWidth,
                onChanged: (value) => setState(() => strokeWidth = value!),
                child: const Column(
                  children: <Widget>[
                    RadioListTile<double>(
                      title: Text('Thin'),
                      value: 1,
                    ),
                    RadioListTile<double>(
                      title: Text('Medium'),
                      value: 5,
                    ),
                    RadioListTile<double>(
                      title: Text('Thick'),
                      value: 10,
                    ),
                    SizedBox(height: 10),
                  ],
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
              widget.onAddPolygon(
                pointCountController.text,
                userDataController.text,
                zIndexController.text,
                selectedColor,
                selectedStrokeColor,
                strokeWidth,
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
