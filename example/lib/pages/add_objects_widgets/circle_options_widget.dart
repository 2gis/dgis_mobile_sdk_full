import 'package:flutter/material.dart';

class CircleOptionsDialog extends StatefulWidget {
  final String initialRadius;
  final String initialUserData;
  final String initialZIndex;
  final int initialSelectedColor;
  final double initialStrokeWidth;
  final int initialSelectedStrokeColor;
  final GlobalKey<FormState> formKey;
  final void Function(
    String radius,
    String userData,
    String zIndex,
    int color,
    double strokeWidth,
    int strokeColor,
  ) onAddCircle;

  const CircleOptionsDialog({
    required this.initialRadius,
    required this.initialUserData,
    required this.initialZIndex,
    required this.initialSelectedColor,
    required this.initialStrokeWidth,
    required this.initialSelectedStrokeColor,
    required this.formKey,
    required this.onAddCircle,
    super.key,
  });

  @override
  CircleOptionsDialogState createState() => CircleOptionsDialogState();
}

class CircleOptionsDialogState extends State<CircleOptionsDialog> {
  late TextEditingController radiusController;
  late TextEditingController userDataController;
  late TextEditingController zIndexController;
  late int selectedColor;
  late double strokeWidth;
  late int selectedStrokeColor;

  @override
  void initState() {
    super.initState();
    radiusController = TextEditingController(text: widget.initialRadius);
    userDataController = TextEditingController(text: widget.initialUserData);
    zIndexController = TextEditingController(text: widget.initialZIndex);
    selectedColor = widget.initialSelectedColor;
    strokeWidth = widget.initialStrokeWidth;
    selectedStrokeColor = widget.initialSelectedStrokeColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Circle options'),
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
                  controller: radiusController,
                  decoration: const InputDecoration(
                    labelText: 'Radius, m',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value for radius';
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
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              const Text('Stroke Width:'),
              RadioGroup<double>(
                groupValue: strokeWidth,
                onChanged: (value) => setState(() => strokeWidth = value!),
                child: const Column(
                  children: <Widget>[
                    RadioListTile<double>(
                      title: Text('None'),
                      value: 0,
                    ),
                    RadioListTile<double>(
                      title: Text('Thin'),
                      value: 1,
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
              widget.onAddCircle(
                radiusController.text,
                userDataController.text,
                zIndexController.text,
                selectedColor,
                strokeWidth,
                selectedStrokeColor,
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
