import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/dart_bindings.dart' as sdk;

import '../../util/plugin_name.dart';
import 'base_map_state.dart';

typedef UriOpener = void Function(
  String uri,
);

class CopyrightAlignment {
  final EdgeInsets edgeInsets;
  final Alignment alignment;

  const CopyrightAlignment([
    this.edgeInsets = const EdgeInsets.all(8),
    this.alignment = Alignment.bottomRight,
  ]);

  CopyrightAlignment copyWith({
    EdgeInsets? edgeInsets,
    Alignment? alignment,
  }) {
    return CopyrightAlignment(
      edgeInsets ?? this.edgeInsets,
      alignment ?? this.alignment,
    );
  }
}

class CopyrightWidgetController {
  final ValueNotifier<CopyrightAlignment> copyrightAlignment =
      ValueNotifier(const CopyrightAlignment());

  UriOpener uriOpener = (uri) async {
    final url = Uri.parse(uri);
    if (!await launchUrl(url)) {
      throw Exception('Failed to open URI');
    }
  };
}

class CopyrightWidget extends StatefulWidget {
  final CopyrightWidgetController _controller;

  CopyrightWidget({
    CopyrightWidgetController? controller,
    super.key,
  }) : _controller = controller ?? CopyrightWidgetController();

  @override
  BaseMapWidgetState<CopyrightWidget> createState() => _CopyrightWidgetState();
}

class _CopyrightState {
  final bool hideCopyright;
  final sdk.ProductType productType;

  const _CopyrightState({
    this.hideCopyright = true,
    this.productType = sdk.ProductType.dgis,
  });

  _CopyrightState copyWith({
    bool? hideCopyright,
    sdk.ProductType? productType,
  }) {
    return _CopyrightState(
      hideCopyright: hideCopyright ?? this.hideCopyright,
      productType: productType ?? this.productType,
    );
  }
}

class _CopyrightWidgetState extends BaseMapWidgetState<CopyrightWidget> {
  final ValueNotifier<_CopyrightState> copyrightState =
      ValueNotifier(const _CopyrightState());
  bool interactive = true;

  StreamSubscription<bool>? interactiveSubscription;
  StreamSubscription<bool>? hideCopyrightSubscription;
  StreamSubscription<sdk.ProductType>? productTypeSubscription;

  @override
  void onAttachedToMap(sdk.Map map) {
    interactiveSubscription = map.interactiveChannel.listen(
      (value) {
        interactive = value;
      },
    );
    hideCopyrightSubscription = map.hideCopyrightChannel.listen(
      (hideCopyright) {
        copyrightState.value =
            copyrightState.value.copyWith(hideCopyright: hideCopyright);
      },
    );
    productTypeSubscription = map.productTypeChannel.listen(
      (productType) {
        copyrightState.value =
            copyrightState.value.copyWith(productType: productType);
      },
    );
  }

  @override
  void onDetachedFromMap() {
    interactiveSubscription?.cancel();
    interactiveSubscription = null;
    hideCopyrightSubscription?.cancel();
    hideCopyrightSubscription = null;
    productTypeSubscription?.cancel();
    hideCopyrightSubscription = null;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_CopyrightState>(
      valueListenable: copyrightState,
      builder: (_, currentState, __) => SafeArea(
        minimum: widget._controller.copyrightAlignment.value.edgeInsets,
        child: _createCopyrightWidget(currentState),
      ),
    );
  }

  Widget _createCopyrightWidget(_CopyrightState currentState) {
    if (currentState.hideCopyright) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      onTap: () {
        if (interactive) {
          widget._controller
              .uriOpener(_getApiUri(copyrightState.value.productType));
        }
      },
      child: SvgPicture.asset(
        _getCopyrightAsset(currentState.productType),
        width: 60,
        height: 30,
      ),
    );
  }

  String _getApiUri(sdk.ProductType productType) {
    switch (productType) {
      case sdk.ProductType.dgis:
        return 'https://dev.2gis.ru';
      case sdk.ProductType.urbi:
        return 'https://urbi.ae/';
    }
  }

  String _getCopyrightAsset(sdk.ProductType productType) {
    switch (productType) {
      case sdk.ProductType.dgis:
        return 'packages/$pluginName/assets/icons/dgis_copyright_icon.svg';
      case sdk.ProductType.urbi:
        return 'packages/$pluginName/assets/icons/urbi_copyright_icon.svg';
    }
  }
}
