import 'package:project_2_graphs/data/models/home/edge.dart';
import 'package:project_2_graphs/data/models/home/graph.dart';
import 'package:project_2_graphs/data/models/home/sequence.dart';

class NetworkData {
  List<Edge> edges = [];
  List<Graph> graphs = [];
  List<Sequence> sequences = [];

  int startingPoint = -1;

  void clean() {
    edges.clear();
    graphs.clear();
    sequences.clear();
    startingPoint = -1;
  }

  void resetStartingPoint() {
    startingPoint = -1;
  }
}
