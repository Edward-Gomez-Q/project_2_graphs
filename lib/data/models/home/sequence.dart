import 'package:project_2_graphs/data/models/home/edge.dart';
import 'package:project_2_graphs/data/models/home/graph.dart';

class Sequence {
  Graph start;
  Graph end;
  double section;
  Edge edge;

  Sequence({
    required this.start,
    required this.end,
    required this.section,
    required this.edge,
  });
}
