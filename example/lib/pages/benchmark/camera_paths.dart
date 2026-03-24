import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;

typedef CameraPath = List<
    (sdk.CameraPosition position, Duration time, sdk.CameraAnimationType type)>;

enum CameraPathType {
  moscowDefault,
  dubaiImmersiveFlight,
  dubaiMallFlight,
  polygonsFlight,
  moscowGeoJson,
}

extension CameraPathTypeExtension on CameraPathType {
  String get name {
    switch (this) {
      case CameraPathType.moscowDefault:
        return 'Moscow';
      case CameraPathType.dubaiImmersiveFlight:
        return 'Dubai Immersive';
      case CameraPathType.dubaiMallFlight:
        return 'Dubai Indoor';
      case CameraPathType.polygonsFlight:
        return 'Polygons';
      case CameraPathType.moscowGeoJson:
        return 'Moscow GeoJson';
    }
  }
}

final Map<CameraPathType, CameraPath> cameraPaths = {
  CameraPathType.moscowDefault: <(
    sdk.CameraPosition position,
    Duration time,
    sdk.CameraAnimationType type
  )>[
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(55.759909),
          longitude: sdk.Longitude(37.618806),
        ),
        zoom: sdk.Zoom(15),
        tilt: sdk.Tilt(15),
        bearing: sdk.Bearing(115),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(55.746962),
          longitude: sdk.Longitude(37.643073),
        ),
        zoom: sdk.Zoom(16),
        tilt: sdk.Tilt(55),
      ),
      const Duration(seconds: 9),
      sdk.CameraAnimationType.showBothPositions,
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(55.746962),
          longitude: sdk.Longitude(37.643073),
        ),
        zoom: sdk.Zoom(16.5),
        tilt: sdk.Tilt(45),
        bearing: sdk.Bearing(40),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear,
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(55.752425),
          longitude: sdk.Longitude(37.613983),
        ),
        zoom: sdk.Zoom(16),
        tilt: sdk.Tilt(25),
        bearing: sdk.Bearing(85),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
  ],
  CameraPathType.dubaiImmersiveFlight: <(
    sdk.CameraPosition position,
    Duration time,
    sdk.CameraAnimationType type
  )>[
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(25.236213145260663),
          longitude: sdk.Longitude(55.29931968078017),
        ),
        zoom: sdk.Zoom(17.9),
        tilt: sdk.Tilt(59),
        bearing: sdk.Bearing(130),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(25.23503475822966),
          longitude: sdk.Longitude(55.30102791264653),
        ),
        zoom: sdk.Zoom(18.396454),
        tilt: sdk.Tilt(60),
        bearing: sdk.Bearing(138.67406837919924),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(25.235042188578717),
          longitude: sdk.Longitude(55.29939528554678),
        ),
        zoom: sdk.Zoom(18.240969),
        tilt: sdk.Tilt(60),
        bearing: sdk.Bearing(252.85139373504663),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(25.234766810440377),
          longitude: sdk.Longitude(55.29980390332639),
        ),
        zoom: sdk.Zoom(17.9),
        tilt: sdk.Tilt(57),
        bearing: sdk.Bearing(330),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(25.234641403999944),
          longitude: sdk.Longitude(55.299516236409545),
        ),
        zoom: sdk.Zoom(17.5),
        tilt: sdk.Tilt(55),
        bearing: sdk.Bearing(15),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(25.228974399135552),
          longitude: sdk.Longitude(55.293875467032194),
        ),
        zoom: sdk.Zoom(18.048622),
        tilt: sdk.Tilt(55.110836),
        bearing: sdk.Bearing(32.35952383455281),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(25.228686041376136),
          longitude: sdk.Longitude(55.29333248734474),
        ),
        zoom: sdk.Zoom(17.202654),
        tilt: sdk.Tilt(52.78325),
        bearing: sdk.Bearing(32.35952383455281),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(25.227277832681466),
          longitude: sdk.Longitude(55.29350431635976),
        ),
        zoom: sdk.Zoom(17.03534),
        tilt: sdk.Tilt(50.82511),
        bearing: sdk.Bearing(99.4318722010513),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(25.227277832681466),
          longitude: sdk.Longitude(55.29350431635976),
        ),
        zoom: sdk.Zoom(17.03534),
        tilt: sdk.Tilt(50.82511),
        bearing: sdk.Bearing(99.4318722010513),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(25.225995553946248),
          longitude: sdk.Longitude(55.292065143585205),
        ),
        zoom: sdk.Zoom(17.157991),
        tilt: sdk.Tilt(51.933483),
        bearing: sdk.Bearing(173.8907969473518),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(25.216675784626034),
          longitude: sdk.Longitude(55.28231372125447),
        ),
        zoom: sdk.Zoom(16.991346),
        tilt: sdk.Tilt(58.743847),
        bearing: sdk.Bearing(214.2997023612303),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(25.21855828300758),
          longitude: sdk.Longitude(55.28217307291925),
        ),
        zoom: sdk.Zoom(16.948515),
        tilt: sdk.Tilt(58.26355),
        bearing: sdk.Bearing(326.7346701380984),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(25.217604411637197),
          longitude: sdk.Longitude(55.28364091180265),
        ),
        zoom: sdk.Zoom(17.065231),
        tilt: sdk.Tilt(56.600986),
        bearing: sdk.Bearing(88.85091196908273),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(25.217908871751177),
          longitude: sdk.Longitude(55.28248144313693),
        ),
        zoom: sdk.Zoom(17.963282),
        tilt: sdk.Tilt(57.660046),
        bearing: sdk.Bearing(153.648165304185),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(25.218712900613397),
          longitude: sdk.Longitude(55.28143144212663),
        ),
        zoom: sdk.Zoom(18.30254),
        tilt: sdk.Tilt(59.10093),
        bearing: sdk.Bearing(221.5413694476013),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(25.218712900613397),
          longitude: sdk.Longitude(55.28143144212663),
        ),
        zoom: sdk.Zoom(18.30254),
        tilt: sdk.Tilt(59.10093),
        bearing: sdk.Bearing(221.5413694476013),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(25.219328639203),
          longitude: sdk.Longitude(55.281034307554364),
        ),
        zoom: sdk.Zoom(17.978739),
        tilt: sdk.Tilt(60),
        bearing: sdk.Bearing(291.26680917454286),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(25.19552087049614),
          longitude: sdk.Longitude(55.27348338626325),
        ),
        zoom: sdk.Zoom(17.297209),
        tilt: sdk.Tilt(47.36454),
        bearing: sdk.Bearing(199.04663318978456),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(25.19777692060545),
          longitude: sdk.Longitude(55.27235861867666),
        ),
        zoom: sdk.Zoom(17.009499),
        tilt: sdk.Tilt(48.620678),
        bearing: sdk.Bearing(288.28687960193633),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(25.198761815275702),
          longitude: sdk.Longitude(55.27509866282344),
        ),
        zoom: sdk.Zoom(17.04467),
        tilt: sdk.Tilt(52.019707),
        bearing: sdk.Bearing(29.089324882599087),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
  ],
  CameraPathType.dubaiMallFlight: <(
    sdk.CameraPosition position,
    Duration time,
    sdk.CameraAnimationType type
  )>[
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(25.194082319043517),
          longitude: sdk.Longitude(55.280991056934),
        ),
        zoom: sdk.Zoom(19.093323),
        tilt: sdk.Tilt(57.192116),
        bearing: sdk.Bearing(342.34027269336525),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(25.196880830939435),
          longitude: sdk.Longitude(55.27838478796184),
        ),
        zoom: sdk.Zoom(19.09329),
        tilt: sdk.Tilt(57.192116),
        bearing: sdk.Bearing(342.34027269336525),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(25.198081961220097),
          longitude: sdk.Longitude(55.278184125199914),
        ),
        zoom: sdk.Zoom(19.81237),
        tilt: sdk.Tilt(58.706905),
        bearing: sdk.Bearing(109.13508482278154),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(25.19779565385268),
          longitude: sdk.Longitude(55.28052309527993),
        ),
        zoom: sdk.Zoom(19.812374),
        tilt: sdk.Tilt(58.706905),
        bearing: sdk.Bearing(109.13508482278154),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(25.197723678729133),
          longitude: sdk.Longitude(55.28058998286724),
        ),
        zoom: sdk.Zoom(20.000002),
        tilt: sdk.Tilt(60),
        bearing: sdk.Bearing(245.8197139845185),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(25.197278782026558),
          longitude: sdk.Longitude(55.279244016855955),
        ),
        zoom: sdk.Zoom(19.993673),
        tilt: sdk.Tilt(59.667492),
        bearing: sdk.Bearing(267.18760563306654),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear
    ),
  ],
  CameraPathType.polygonsFlight: <(
    sdk.CameraPosition position,
    Duration time,
    sdk.CameraAnimationType type
  )>[
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(57.314785544219696),
          longitude: sdk.Longitude(40.067282589152455),
        ),
        zoom: sdk.Zoom(8.674324),
        tilt: sdk.Tilt(26.896542),
        bearing: sdk.Bearing(332.9909731536684),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear,
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(57.589794514898976),
          longitude: sdk.Longitude(39.91194723173976),
        ),
        zoom: sdk.Zoom(12.360521),
        tilt: sdk.Tilt(20.948286),
        bearing: sdk.Bearing(332.9909731536684),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear,
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(57.397910969166645),
          longitude: sdk.Longitude(40.11585362255573),
        ),
        zoom: sdk.Zoom(8.523351),
        tilt: sdk.Tilt(17.17982),
        bearing: sdk.Bearing(332.9909731536684),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear,
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(57.52634636371139),
          longitude: sdk.Longitude(39.938956908881664),
        ),
        zoom: sdk.Zoom(10.49659),
        tilt: sdk.Tilt(28.81773),
        bearing: sdk.Bearing(332.9909731536684),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear,
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(57.64800139263117),
          longitude: sdk.Longitude(39.84729182906449),
        ),
        zoom: sdk.Zoom(11.320579),
        tilt: sdk.Tilt(28.263542),
        bearing: sdk.Bearing(332.9909731536684),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear,
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(57.7489827569871),
          longitude: sdk.Longitude(39.775858987122774),
        ),
        zoom: sdk.Zoom(14.971335),
        tilt: sdk.Tilt(43.161377),
        bearing: sdk.Bearing(171.3057889125554),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear,
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(57.72653680666681),
          longitude: sdk.Longitude(39.78192748501897),
        ),
        zoom: sdk.Zoom(14.972231),
        tilt: sdk.Tilt(43.161377),
        bearing: sdk.Bearing(171.3057889125554),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear,
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(57.617886055721506),
          longitude: sdk.Longitude(39.91270562633872),
        ),
        zoom: sdk.Zoom(15.217519),
        tilt: sdk.Tilt(28.706902),
        bearing: sdk.Bearing(165.9114967513761),
      ),
      const Duration(seconds: 8),
      sdk.CameraAnimationType.linear,
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(57.61881994336016),
          longitude: sdk.Longitude(39.890154115855694),
        ),
        zoom: sdk.Zoom(15.951988),
        tilt: sdk.Tilt(43.965538),
        bearing: sdk.Bearing(305.49698921588754),
      ),
      const Duration(seconds: 8),
      sdk.CameraAnimationType.linear,
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(57.62419202445006),
          longitude: sdk.Longitude(39.90131906233728),
        ),
        zoom: sdk.Zoom(18.219717),
        tilt: sdk.Tilt(59.852222),
        bearing: sdk.Bearing(3.2874246890404972),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear,
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(57.624294132215994),
          longitude: sdk.Longitude(39.90163723938167),
        ),
        zoom: sdk.Zoom(18.326157),
        tilt: sdk.Tilt(57.007397),
        bearing: sdk.Bearing(171.01849749568632),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear,
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(57.62419202445006),
          longitude: sdk.Longitude(39.90131906233728),
        ),
        zoom: sdk.Zoom(18.219717),
        tilt: sdk.Tilt(59.852222),
        bearing: sdk.Bearing(340.2874246890405),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear,
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(57.624294132215994),
          longitude: sdk.Longitude(39.90163723938167),
        ),
        zoom: sdk.Zoom(18.326157),
        tilt: sdk.Tilt(57.007397),
        bearing: sdk.Bearing(150.01849749568632),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear,
    ),
  ],
  CameraPathType.moscowGeoJson: <(
    sdk.CameraPosition position,
    Duration time,
    sdk.CameraAnimationType type
  )>[
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(55.861064234816034),
          longitude: sdk.Longitude(37.477319184690714),
        ),
        zoom: sdk.Zoom(9.135463),
        tilt: sdk.Tilt(25.102968),
        bearing: sdk.Bearing(85.00001033389452),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear,
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(55.77195937179973),
          longitude: sdk.Longitude(37.72410722449422),
        ),
        zoom: sdk.Zoom(9.464503),
        tilt: sdk.Tilt(25.205942),
        bearing: sdk.Bearing(196.61411595839786),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear,
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(55.66136007366556),
          longitude: sdk.Longitude(37.86856823600829),
        ),
        zoom: sdk.Zoom(9.317101),
        tilt: sdk.Tilt(23.043468),
        bearing: sdk.Bearing(284.3648893578667),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear,
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(55.563076406731504),
          longitude: sdk.Longitude(37.7226300816983),
        ),
        zoom: sdk.Zoom(10.972983),
        tilt: sdk.Tilt(30),
        bearing: sdk.Bearing(263.17395425033527),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear,
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(55.621818396123),
          longitude: sdk.Longitude(37.43075570091605),
        ),
        zoom: sdk.Zoom(12.166465),
        tilt: sdk.Tilt(30),
        bearing: sdk.Bearing(311.93437420673285),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear,
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(55.79354205270647),
          longitude: sdk.Longitude(37.37391768023372),
        ),
        zoom: sdk.Zoom(12.391051),
        tilt: sdk.Tilt(30),
        bearing: sdk.Bearing(359.6923682797826),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear,
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(55.852668022608036),
          longitude: sdk.Longitude(37.39984408020973),
        ),
        zoom: sdk.Zoom(13.670622),
        tilt: sdk.Tilt(30),
        bearing: sdk.Bearing(16.634707157512615),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear,
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(55.86831862804825),
          longitude: sdk.Longitude(37.53497410565615),
        ),
        zoom: sdk.Zoom(14.797172),
        tilt: sdk.Tilt(29.176205),
        bearing: sdk.Bearing(111.84492139484908),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear,
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(55.84166953081042),
          longitude: sdk.Longitude(37.57578014396131),
        ),
        zoom: sdk.Zoom(14.798161),
        tilt: sdk.Tilt(29.176205),
        bearing: sdk.Bearing(111.84492139484908),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear,
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(55.83614089961442),
          longitude: sdk.Longitude(37.60718487203121),
        ),
        zoom: sdk.Zoom(11.284859),
        tilt: sdk.Tilt(26.25859),
        bearing: sdk.Bearing(101.15870794777061),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear,
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(55.68093117094693),
          longitude: sdk.Longitude(37.44317131116986),
        ),
        zoom: sdk.Zoom(10.287172),
        tilt: sdk.Tilt(30),
        bearing: sdk.Bearing(35.66980233655617),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear,
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(55.52392517533765),
          longitude: sdk.Longitude(37.33199282549322),
        ),
        zoom: sdk.Zoom(9.250065),
        tilt: sdk.Tilt(17.746012),
        bearing: sdk.Bearing(35.66980233655617),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear,
    ),
    (
      const sdk.CameraPosition(
        point: sdk.GeoPoint(
          latitude: sdk.Latitude(55.58099451422654),
          longitude: sdk.Longitude(37.41593699902296),
        ),
        zoom: sdk.Zoom(8.413875),
        tilt: sdk.Tilt(12.528627),
        bearing: sdk.Bearing(35.66980233655617),
      ),
      const Duration(seconds: 4),
      sdk.CameraAnimationType.linear,
    ),
  ],
};
