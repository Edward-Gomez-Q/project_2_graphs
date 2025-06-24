class Sketch {
  double x1;
  double y1;
  double x2;
  double y2;
  bool isDrawing;

  Sketch({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    this.isDrawing = false,
  });
}
