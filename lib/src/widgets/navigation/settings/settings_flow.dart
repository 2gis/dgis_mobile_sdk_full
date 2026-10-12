import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/dgis_localizations.dart';
import '../../../../l10n/generated/dgis_localizations_en.dart';
import 'bicycle_route_settings_layout.dart';
import 'car_route_settings_layout.dart';
import 'motorcycle_route_settings_layout.dart';
import 'navigation_settings_repository.dart';
import 'navigation_settings_text_scope.dart';
import 'navigation_settings_theme.dart';
import 'pedestrian_route_settings_layout.dart';
import 'public_transport_route_settings_layout.dart';
import 'route_settings_layout.dart';
import 'scooter_route_settings_layout.dart';
import 'section_visibility_config.dart';
import 'settings_layout_helpers.dart';
import 'sound_settings_layout.dart';
import 'truck_route_settings_layout.dart';
import 'voices_screen.dart';

const _transitionDuration = Duration(milliseconds: 300);

abstract final class _SettingsRoutes {
  static const root = '/';
  static const car = '/car';
  static const pedestrian = '/pedestrian';
  static const bicycle = '/bicycle';
  static const scooter = '/scooter';
  static const motorcycle = '/motorcycle';
  static const publicTransport = '/public-transport';
  static const truck = '/truck';
  static const sounds = '/sounds';
  static const voices = '/voices';
  static const voiceLanguage = '/voices/language';
}

Future<void> showNavigationSettingsFlow({
  required BuildContext context,
  required NavigationSettingsRepository repository,
  required String primarySection,
  required SectionVisibilityConfig visibilityConfig,
  NavigationSettingsTheme? theme,
}) {
  final resolvedTheme = resolveNavigationSettingsTheme(context, theme);
  return showGeneralDialog<void>(
    context: context,
    barrierColor: Colors.transparent,
    transitionDuration: _transitionDuration,
    pageBuilder: (dialogContext, animation, secondaryAnimation) =>
        _SettingsFlow(
      repository: repository,
      primarySection: primarySection,
      visibilityConfig: visibilityConfig,
      theme: resolvedTheme,
      onClose: () => Navigator.of(dialogContext).pop(),
    ),
    transitionBuilder: (context, animation, secondaryAnimation, child) =>
        SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
      child: child,
    ),
  );
}

class _SettingsFlow extends StatefulWidget {
  final NavigationSettingsRepository repository;
  final String primarySection;
  final SectionVisibilityConfig visibilityConfig;
  final NavigationSettingsTheme theme;
  final VoidCallback onClose;

  const _SettingsFlow({
    required this.repository,
    required this.primarySection,
    required this.visibilityConfig,
    required this.theme,
    required this.onClose,
  });

  @override
  State<_SettingsFlow> createState() => _SettingsFlowState();
}

class _SettingsFlowState extends State<_SettingsFlow> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  String? _voiceLanguage;

  Future<bool> _handleBack() async {
    final navigator = _navigatorKey.currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
      return false;
    }
    return true;
  }

  void _open(String route) => _navigatorKey.currentState!.pushNamed(route);

  @override
  // ignore: deprecated_member_use
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: _handleBack,
        child: navigationSettingsTextScope(
          theme: widget.theme,
          child: Navigator(
            key: _navigatorKey,
            initialRoute: _SettingsRoutes.root,
            onGenerateRoute: _onGenerateRoute,
          ),
        ),
      );

  Route<void> _onGenerateRoute(RouteSettings settings) {
    final localizations =
        DgisLocalizations.of(context) ?? DgisLocalizationsEn();
    final isFullHeightRoute = settings.name == _SettingsRoutes.root ||
        settings.name == _SettingsRoutes.sounds ||
        settings.name == _SettingsRoutes.voices ||
        settings.name == _SettingsRoutes.voiceLanguage;

    return PageRouteBuilder<void>(
      settings: settings,
      transitionDuration: settings.name == _SettingsRoutes.root
          ? Duration.zero
          : _transitionDuration,
      reverseTransitionDuration: settings.name == _SettingsRoutes.root
          ? Duration.zero
          : _transitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) {
        final (title, content, onBack) = _pageFor(settings, localizations);

        return _SettingsScreen(
          title: title,
          onBack: onBack,
          theme: widget.theme,
          child: isFullHeightRoute
              ? content
              : SingleChildScrollView(child: content),
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      ),
    );
  }

  (String, Widget, VoidCallback) _pageFor(
    RouteSettings settings,
    DgisLocalizations localizations,
  ) =>
      switch (settings.name) {
        _SettingsRoutes.root => (
            localizations.dgis_settings_title,
            RouteSettingsLayout(
              repository: widget.repository,
              primarySection: widget.primarySection,
              theme: widget.theme,
              visibilityConfig: widget.visibilityConfig,
              onNavigateToCar: () => _open(_SettingsRoutes.car),
              onNavigateToPedestrian: () => _open(_SettingsRoutes.pedestrian),
              onNavigateToBicycle: () => _open(_SettingsRoutes.bicycle),
              onNavigateToScooter: () => _open(_SettingsRoutes.scooter),
              onNavigateToMotorcycle: () => _open(_SettingsRoutes.motorcycle),
              onNavigateToPublicTransport: () =>
                  _open(_SettingsRoutes.publicTransport),
              onNavigateToTruck: () => _open(_SettingsRoutes.truck),
              onNavigateToSounds: () => _open(_SettingsRoutes.sounds),
              onNavigateToVoices: () => _open(_SettingsRoutes.voices),
            ),
            widget.onClose,
          ),
        _SettingsRoutes.car => (
            localizations.dgis_settings_section_car,
            CarRouteSettingsLayout(
              repository: widget.repository,
              theme: widget.theme,
            ),
            () => _navigatorKey.currentState!.pop(),
          ),
        _SettingsRoutes.pedestrian => (
            localizations.dgis_settings_section_pedestrian,
            PedestrianRouteSettingsLayout(
              repository: widget.repository,
              theme: widget.theme,
            ),
            () => _navigatorKey.currentState!.pop(),
          ),
        _SettingsRoutes.bicycle => (
            localizations.dgis_settings_section_bicycle,
            BicycleRouteSettingsLayout(
              repository: widget.repository,
              theme: widget.theme,
            ),
            () => _navigatorKey.currentState!.pop(),
          ),
        _SettingsRoutes.scooter => (
            localizations.dgis_settings_section_scooter,
            ScooterRouteSettingsLayout(
              repository: widget.repository,
              theme: widget.theme,
            ),
            () => _navigatorKey.currentState!.pop(),
          ),
        _SettingsRoutes.motorcycle => (
            localizations.dgis_settings_section_motorcycle,
            MotorcycleRouteSettingsLayout(
              repository: widget.repository,
              theme: widget.theme,
            ),
            () => _navigatorKey.currentState!.pop(),
          ),
        _SettingsRoutes.publicTransport => (
            localizations.dgis_settings_section_public_transport,
            PublicTransportRouteSettingsLayout(
              repository: widget.repository,
              theme: widget.theme,
            ),
            () => _navigatorKey.currentState!.pop(),
          ),
        _SettingsRoutes.truck => (
            localizations.dgis_settings_truck_title,
            TruckRouteSettingsLayout(
              repository: widget.repository,
              theme: widget.theme,
            ),
            () => _navigatorKey.currentState!.pop(),
          ),
        _SettingsRoutes.sounds => (
            localizations.dgis_settings_sounds_and_alerts,
            SoundSettingsLayout(
              repository: widget.repository,
              visibilityConfig: widget.visibilityConfig,
              theme: widget.theme,
              onNavigateToVoices: () => _open(_SettingsRoutes.voices),
            ),
            () => _navigatorKey.currentState!.pop(),
          ),
        _SettingsRoutes.voices => (
            localizations.dgis_settings_voices,
            VoicesLayout(
              repository: widget.repository,
              selectedLanguage: _voiceLanguage,
              onNavigateToLanguageSelection: () =>
                  _open(_SettingsRoutes.voiceLanguage),
              theme: widget.theme,
              visibilityConfig: widget.visibilityConfig,
            ),
            () => _navigatorKey.currentState!.pop(),
          ),
        _SettingsRoutes.voiceLanguage => (
            localizations.dgis_settings_voices_language_selection,
            VoicesLanguageLayout(
              selectedLanguage: _voiceLanguage,
              onLanguageSelected: (language) {
                setState(() => _voiceLanguage = language);
                _navigatorKey.currentState!.pop();
              },
              theme: widget.theme,
            ),
            () => _navigatorKey.currentState!.pop(),
          ),
        _ => throw ArgumentError.value(settings.name, 'settings.name'),
      };
}

class _SettingsScreen extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final NavigationSettingsTheme theme;
  final Widget child;

  const _SettingsScreen({
    required this.title,
    required this.onBack,
    required this.theme,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
        backgroundColor: theme.colors.pickerBackground,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: theme.colors.pickerBackground,
          border: Border(bottom: BorderSide(color: theme.colors.divider)),
          // Keep the bar and its bottom hairline visible before any scroll.
          automaticBackgroundVisibility: false,
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onBack,
            child: Icon(
              CupertinoIcons.back,
              color: theme.colors.settingLabel,
            ),
          ),
          middle: navigationSettingsTextScope(
            theme: theme,
            child: Text(
              title,
              style: theme.typography.screenTitle.copyWith(
                color: theme.colors.settingLabel,
              ),
            ),
          ),
        ),
        child: SafeArea(top: false, child: child),
      );
}
