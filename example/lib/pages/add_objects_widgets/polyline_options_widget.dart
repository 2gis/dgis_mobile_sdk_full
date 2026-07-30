import 'package:flutter/material.dart';

class PolylineOptionsDialog extends StatefulWidget {
  final String initialPointCount;
  final String initialUserData;
  final String initialZIndex;
  final double initialWidth;
  final int initialSelectedColor;
  final GlobalKey<FormState> formKey;
  final void Function(
    String pointCount,
    String userData,
    String zIndex,
    double width,
    int color,
  ) onAddPolyline;

  const PolylineOptionsDialog({
    required this.initialPointCount,
    required this.initialUserData,
    required this.initialZIndex,
    required this.initialWidth,
    required this.initialSelectedColor,
    required this.formKey,
    required this.onAddPolyline,
    super.key,
  });

  @override
  PolylineOptionsDialogState createState() => PolylineOptionsDialogState();
}

class PolylineOptionsDialogState extends State<PolylineOptionsDialog> {
  late TextEditingController pointCountController;
  late TextEditingController userDataController;
  late TextEditingController zIndexController;
  late double width;
  late int selectedColor;

  @override
  void initState() {
    super.initState();
    pointCountController =
        TextEditingController(text: widget.initialPointCount);
    userDataController = TextEditingController(text: widget.initialUserData);
    zIndexController = TextEditingController(text: widget.initialZIndex);
    width = widget.initialWidth;
    selectedColor = widget.initialSelectedColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Polyline options'),
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
              const Text('Width:'),
              Column(
                children: <Widget>[
                  RadioListTile<double>(
                    title: const Text('Thin'),
                    value: 1,
                    groupValue: width,
                    onChanged: (value) => setState(() => width = value!),
                  ),
                  RadioListTile<double>(
                    title: const Text('Medium'),
                    value: 5,
                    groupValue: width,
                    onChanged: (value) => setState(() => width = value!),
                  ),
                  RadioListTile<double>(
                    title: const Text('Thick'),
                    value: 10,
                    groupValue: width,
                    onChanged: (value) => setState(() => width = value!),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
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
              widget.onAddPolyline(
                pointCountController.text,
                userDataController.text,
                zIndexController.text,
                width,
                selectedColor,
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
