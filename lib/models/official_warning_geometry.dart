class OfficialWarningGeometry {
  final List<List<List<double>>> polygons;

  const OfficialWarningGeometry({required this.polygons});

  bool get isEmpty => polygons.isEmpty;
}
