import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

import '../../generated/dart_bindings.dart' as sdk;

/// Класс для загрузки объемных моделей.
class ModelLoader {
  final sdk.Context _sdkContext;

  ModelLoader(this._sdkContext);

  /// Загрузить модель из assets.
  Future<sdk.ModelData> loadFromAsset(String name) async {
    final data = await rootBundle.load(name);
    return _makeModelData(data);
  }

  /// Загрузить модель из файла.
  Future<sdk.ModelData> loadFromFile(String path) async {
    final data = await _loadFromFile(path);
    return _makeModelData(data);
  }

  Future<ByteData> _loadFromFile(String path) async {
    final fileUri = Uri.parse(path);
    final file = File.fromUri(fileUri);
    final bytes = await file.readAsBytes();
    return ByteData.view(bytes.buffer);
  }

  sdk.ModelData _makeModelData(ByteData data) {
    final loader = _ModelDataLoader(data);
    return sdk.createModelData(_sdkContext, loader);
  }
}

class _ModelDataLoader extends sdk.ModelDataLoader {
  final ByteData _modelData;

  _ModelDataLoader(ByteData data) : _modelData = data;

  @override
  ByteData load() => _modelData;
}
