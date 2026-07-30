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
              Column(
                children: <Widget>[
                  RadioListTile<int>(
                    title: const Text('Black'),
                    // ignore: deprecated_member_use
                    value: Colors.black.value,
                    groupValue: selectedColor,
                    onChanged: (value) =>
                        setState(() => selectedColor = value!),
                  ),
                  RadioListTile<int>(
                    title: const Text('Red'),
                    // ignore: deprecated_member_use
                    value: Colors.red.value,
                    groupValue: selectedColor,
                    onChanged: (value) =>
                        setState(() => selectedColor = value!),
                  ),
                  RadioListTile<int>(
                    title: const Text('Blue'),
                    // ignore: deprecated_member_use
                    value: Colors.blue.value,
                    groupValue: selectedColor,
                    onChanged: (value) =>
                        setState(() => selectedColor = value!),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text('Stroke Color:'),
              Column(
                children: <Widget>[
                  RadioListTile<int>(
                    title: const Text('Black'),
                    // ignore: deprecated_member_use
                    value: Colors.black.value,
                    groupValue: selectedStrokeColor,
                    onChanged: (value) =>
                        setState(() => selectedStrokeColor = value!),
                  ),
                  RadioListTile<int>(
                    title: const Text('Red'),
                    // ignore: deprecated_member_use
                    value: Colors.red.value,
                    groupValue: selectedStrokeColor,
                    onChanged: (value) =>
                        setState(() => selectedStrokeColor = value!),
                  ),
                  RadioListTile<int>(
                    title: const Text('Blue'),
                    // ignore: deprecated_member_use
                    value: Colors.blue.value,
                    groupValue: selectedStrokeColor,
                    onChanged: (value) =>
                        setState(() => selectedStrokeColor = value!),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text('Width:'),
              Column(
                children: <Widget>[
                  RadioListTile<double>(
                    title: const Text('Thin'),
                    value: 1,
                    groupValue: strokeWidth,
                    onChanged: (value) => setState(() => strokeWidth = value!),
                  ),
                  RadioListTile<double>(
                    title: const Text('Medium'),
                    value: 5,
                    groupValue: strokeWidth,
                    onChanged: (value) => setState(() => strokeWidth = value!),
                  ),
                  RadioListTile<double>(
                    title: const Text('Thick'),
                    value: 10,
                    groupValue: strokeWidth,
                    onChanged: (value) => setState(() => strokeWidth = value!),
                  ),
                  const SizedBox(height: 10),
                ],
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
