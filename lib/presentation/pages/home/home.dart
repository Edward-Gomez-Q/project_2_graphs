import 'package:flutter/material.dart';
import 'package:project_2_graphs/data/models/home/edge.dart';
import 'package:project_2_graphs/data/models/home/graph.dart';
import 'package:project_2_graphs/data/models/home/network_data.dart';
import 'package:project_2_graphs/data/models/home/operation_mod.dart';
import 'package:project_2_graphs/data/models/home/sequence.dart';
import 'package:project_2_graphs/data/paints/home/graphics.dart';
import 'package:project_2_graphs/presentation/pages/home/widgets/mod_button.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  OperationMod _operationMod = OperationMod.notSelected;
  final NetworkData _networkData = NetworkData();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  void _initAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _controller.addListener(() {
      setState(() {});
    });
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: CustomPaint(
              painter: PaintNN(
                graphs: _networkData.graphs,
                edges: _networkData.edges,
                sequences: _networkData.sequences,
                sketch: _networkData.sketch,
                progress: _controller.value,
                borderColor: Theme.of(context).colorScheme.onSurface,
              ),
              child: Container(
                height: double.infinity,
                width: double.infinity,
                color: Colors.transparent,
                child: GestureDetector(
                  onPanDown: _handleTouch,
                  onPanStart: _handleDragStart,
                  onPanUpdate: _handleDragUpdate,
                  onPanEnd: _handleDragEnd,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      color: Theme.of(context).colorScheme.surface,
      shape: const CircularNotchedRectangle(),
      elevation: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [const SizedBox(width: 5), ..._buildModeButtons()],
      ),
    );
  }

  List<Widget> _buildModeButtons() {
    final buttons = [
      ModButton(
        mod: OperationMod.addGraph,
        icon: Icons.add,
        actualMod: _operationMod,
        onPressed: () => _changeMod(OperationMod.addGraph),
      ),
      ModButton(
        mod: OperationMod.moveGraph,
        icon: Icons.move_down_outlined,
        actualMod: _operationMod,
        onPressed: () => _changeMod(OperationMod.moveGraph),
      ),
      ModButton(
        mod: OperationMod.addEdge,
        icon: Icons.route_outlined,
        actualMod: _operationMod,
        onPressed: () => _changeMod(OperationMod.addEdge),
      ),
      ModButton(
        mod: OperationMod.addSequence,
        icon: Icons.arrow_forward_ios_outlined,
        actualMod: _operationMod,
        onPressed: () => _changeMod(OperationMod.addSequence),
      ),

      ModButton(
        mod: OperationMod.deleteAll,
        icon: Icons.delete,
        actualMod: _operationMod,
        onPressed: () => _changeMod(OperationMod.deleteAll),
      ),
    ];

    return buttons
        .map(
          (boton) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: boton,
          ),
        )
        .toList();
  }

  void _changeMod(OperationMod mod) {
    setState(() {
      _operationMod = mod;
      if (mod == OperationMod.deleteAll) {
        _networkData.clean();
      } else if (mod == OperationMod.addGraph ||
          mod == OperationMod.addEdge ||
          mod == OperationMod.addSequence) {
        _networkData.resetStartingPoint();
      }
    });
  }

  void _handleTouch(DragDownDetails details) {
    final position = details.localPosition;
    switch (_operationMod) {
      case OperationMod.addGraph:
        _addGraph(position);
        break;
      case OperationMod.addSequence:
        _addSequence(position);
        break;
      default:
        break;
    }
  }

  void _handleDragStart(DragStartDetails details) {
    final position = details.localPosition;
    switch (_operationMod) {
      case OperationMod.moveGraph:
        _moveGraphStart(position);
        break;
      case OperationMod.addEdge:
        _initSketchLine(position);
        break;
      default:
        break;
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_operationMod == OperationMod.moveGraph &&
        _networkData.startingPoint >= 0) {
      _moveGraphUpdate(details);
    } else if (_operationMod == OperationMod.addEdge &&
        _networkData.startingPoint >= 0) {
      dragSketchLine(details);
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_operationMod == OperationMod.moveGraph &&
        _networkData.startingPoint >= 0) {
      _moveGraphEnd(details);
    } else if (_operationMod == OperationMod.addEdge &&
        _networkData.startingPoint >= 0) {
      _addEdge(Offset(_networkData.sketch.x2, _networkData.sketch.y2));
    }
  }

  void _addGraph(Offset position) {
    setState(() {
      _networkData.graphs.add(
        Graph(
          x: position.dx,
          y: position.dy,
          radius: 20.0,
          color: Colors.blue,
          opositeColor: Colors.red,
          label: "",
        ),
      );
    });
  }

  void _initSketchLine(Offset position) {
    final graphPosition = _findGraphAtPosition(position);
    if (graphPosition >= 0) {
      setState(() {
        _networkData.sketch.x1 = _networkData.graphs[graphPosition].x;
        _networkData.sketch.y1 = _networkData.graphs[graphPosition].y;

        _networkData.startingPoint = graphPosition;
        _networkData.sketch.isDrawing = true;
      });
    } else {
      _networkData.resetSketch();
    }
  }

  void dragSketchLine(DragUpdateDetails details) {
    final position = details.localPosition;
    setState(() {
      _networkData.sketch.x2 = position.dx;
      _networkData.sketch.y2 = position.dy;
    });
  }

  void _addEdge(Offset position) {
    final graphPosition = _findGraphAtPosition(position);
    if (graphPosition >= 0) {
      setState(() {
        if (_networkData.startingPoint == -1) {
          _networkData.startingPoint = graphPosition;
        } else {
          final startGraph = _networkData.graphs[_networkData.startingPoint];
          final endGraph = _networkData.graphs[graphPosition];
          _networkData.edges.add(
            Edge(
              start: startGraph,
              end: endGraph,
              isSelected: false,
              color: Colors.black,
              weight: 1.0,
            ),
          );
          _networkData.resetStartingPoint();
          _networkData.resetSketch();
        }
      });
    } else {
      _networkData.resetSketch();
    }
  }

  void _addSequence(Offset position) {
    final graphPosition = _findGraphAtPosition(position);
    if (graphPosition >= 0) {
      setState(() {
        if (_networkData.startingPoint == -1) {
          _networkData.startingPoint = graphPosition;
        } else {
          final startGraph = _networkData.graphs[_networkData.startingPoint];
          final endGraph = _networkData.graphs[graphPosition];
          _networkData.sequences.add(
            Sequence(start: startGraph, end: endGraph, section: 0.0),
          );
          _networkData.resetStartingPoint();
        }
      });
    }
  }

  void _moveGraphStart(Offset position) {
    final graphPosition = _findGraphAtPosition(position);
    if (graphPosition >= 0) {
      setState(() {
        _networkData.startingPoint = graphPosition;
        _networkData.graphs[graphPosition].isSelected = true;
      });
    } else {
      _networkData.resetStartingPoint();
    }
  }

  void _moveGraphUpdate(DragUpdateDetails details) {
    final position = details.localPosition;
    if (_operationMod == OperationMod.moveGraph &&
        _networkData.startingPoint >= 0) {
      setState(() {
        final graph = _networkData.graphs[_networkData.startingPoint];
        graph.x = position.dx;
        graph.y = position.dy;
      });
    }
  }

  void _moveGraphEnd(DragEndDetails details) {
    if (_operationMod == OperationMod.moveGraph &&
        _networkData.startingPoint >= 0) {
      setState(() {
        _networkData.graphs[_networkData.startingPoint].isSelected = false;
        _networkData.resetStartingPoint();
      });
    }
  }

  int _findGraphAtPosition(Offset position) {
    for (int i = 0; i < _networkData.graphs.length; i++) {
      final graph = _networkData.graphs[i];
      if ((position.dx - graph.x).abs() <= graph.radius &&
          (position.dy - graph.y).abs() <= graph.radius) {
        return i;
      }
    }
    return -1;
  }
}
