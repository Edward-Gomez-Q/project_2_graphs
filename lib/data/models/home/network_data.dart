import 'package:project_2_graphs/data/models/home/edge.dart';
import 'package:project_2_graphs/data/models/home/graph.dart';
import 'package:project_2_graphs/data/models/home/sequence.dart';
import 'package:project_2_graphs/data/models/home/sketch.dart';

class NetworkData {
  List<Edge> edges = [];
  List<Graph> graphs = [];
  List<Sequence> sequences = [];
  Sketch sketch = Sketch(x1: 0, y1: 0, x2: 0, y2: 0, isDrawing: false);

  int startingPoint = -1;

  void clean() {
    edges.clear();
    graphs.clear();
    sequences.clear();
    startingPoint = -1;
    sketch = Sketch(x1: 0, y1: 0, x2: 0, y2: 0, isDrawing: false);
  }

  void resetStartingPoint() {
    startingPoint = -1;
  }

  void resetSketch() {
    sketch = Sketch(x1: 0, y1: 0, x2: 0, y2: 0, isDrawing: false);
  }
}
