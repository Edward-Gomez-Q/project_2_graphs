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

  void reset() {
    x1 = y1 = x2 = y2 = 0;
    isDrawing = false;
  }
}
