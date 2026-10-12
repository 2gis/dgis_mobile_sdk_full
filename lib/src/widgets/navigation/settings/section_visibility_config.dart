import 'package:flutter/widgets.dart';

/// Controls which navigation settings sections are displayed.
///
/// All sections are visible by default. Add section identifiers to
/// [hiddenSections] to hide them. Hiding a parent section hides that section
/// together with its contents; unknown identifiers have no effect.
@immutable
class SectionVisibilityConfig {
  /// Section identifiers that are hidden from their corresponding settings
  /// screens.
  final Set<String> hiddenSections;

  const SectionVisibilityConfig({
    this.hiddenSections = const <String>{},
  });

  /// Whether the section identified by [section] should be displayed.
  bool isVisible(String section) => !hiddenSections.contains(section);

  // Route settings.
  static const String sectionGeneralRoute = 'section.general_route';
  static const String sectionCarRoute = 'section.car_route';
  static const String sectionCalloutVisualization =
      'section.callout_visualization';
  static const String sectionMapEvents = 'section.map_events';
  static const String sectionPassedRoute = 'section.passed_route';
  static const String sectionNavigationLinks = 'section.navigation_links';
  static const String sectionPedestrian = 'section.pedestrian';
  static const String sectionBicycle = 'section.bicycle';
  static const String sectionScooter = 'section.scooter';
  static const String sectionMotorcycle = 'section.motorcycle';
  static const String sectionPublicTransport = 'section.public_transport';
  static const String sectionTruck = 'section.truck';
  static const String sectionSounds = 'section.sounds';
  static const String sectionSoundGeneral = 'section.sound_general';
  static const String sectionEventWarnings = 'section.event_warnings';
  static const String sectionCameras = 'section.cameras';
  static const String sectionRoadEvents = 'section.road_events';
  static const String sectionVoices = 'section.voices';
  static const String sectionDownloadedVoices = 'section.downloaded_voices';
  static const String sectionAvailableVoices = 'section.available_voices';
  static const String sectionLanguagePicker = 'section.language_picker';
}
