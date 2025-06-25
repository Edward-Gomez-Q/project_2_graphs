import 'package:flutter/material.dart';
import 'package:project_2_graphs/data/models/home/edge.dart';
import 'package:project_2_graphs/data/models/home/graph.dart';
import 'package:project_2_graphs/data/models/home/graph_type.dart';
import 'package:project_2_graphs/data/models/home/network_data.dart';
import 'package:project_2_graphs/data/models/home/operation_mod.dart';
import 'package:project_2_graphs/data/models/home/sequence.dart';
import 'package:project_2_graphs/data/paints/home/graphics.dart';
import 'package:project_2_graphs/presentation/pages/home/widgets/bias_input_dialog.dart';
import 'package:project_2_graphs/presentation/pages/home/widgets/graph_type_selector.dart';
import 'package:project_2_graphs/presentation/pages/home/widgets/mod_button.dart';
import 'package:project_2_graphs/presentation/pages/home/widgets/training_panel.dart';
import 'package:project_2_graphs/presentation/pages/home/widgets/weight_input_dialog.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  OperationMod _operationMod = OperationMod.notSelected;
  final NetworkData _networkData = NetworkData();

  late AnimationController _controller;
  late final Duration _animationDuration = const Duration(seconds: 2);

  bool _showTrainingPanel = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  void _initAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );
    _controller.addListener(() {
      setState(() {});
    });
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleTrainingPanel,
        child: Icon(_showTrainingPanel ? Icons.close : Icons.table_chart),
      ),
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
                isTraining: _networkData.isTraining,
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
          if (_showTrainingPanel)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: TrainingPanel(networkData: _networkData),
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
        onPressed: () => _showGraphTypeSelector(),
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
      ModButton(
        mod: OperationMod.training,
        icon: Icons.play_arrow,
        actualMod: _operationMod,
        onPressed: () => _changeMod(OperationMod.training),
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

  void _showGraphTypeSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => GraphTypeSelector(
        onTypeSelected: (type) {
          Navigator.pop(context);
          _changeMod(OperationMod.addGraph);
          _pendingGraphType = type;
        },
      ),
    );
  }

  GraphType _pendingGraphType = GraphType.perceptron;

  void _changeMod(OperationMod mod) {
    setState(() {
      _operationMod = mod;
      if (mod == OperationMod.deleteAll) {
        _networkData.clean();
      } else if (mod == OperationMod.addGraph ||
          mod == OperationMod.addEdge ||
          mod == OperationMod.addSequence ||
          mod == OperationMod.training) {
        _networkData.resetStartingPoint();
      }
    });
  }

  void _toggleTrainingPanel() {
    setState(() {
      _showTrainingPanel = !_showTrainingPanel;
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
      case OperationMod.training:
        _startTraining(position);
        break;
      default:
        break;
    }
  }

  void _startTraining(Offset position) {
    if (_networkData.graphs.isEmpty) return;
    final graphPosition = _findGraphAtPosition(position);
    if (graphPosition >= 0) {
      final graph = _networkData.graphs[graphPosition];
      // Verificar que el grafo seleccionado sea de tipo perceptrón y que no tenga conexiones de salida
      if (graph.type == GraphType.perceptron &&
          (graph.outputsGraphs == null || graph.outputsGraphs!.isEmpty)) {
        setState(() {
          _networkData.startMultilayerTraining(graph, _animationDuration);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Seleccione un perceptron para entrenar'),
          ),
        );
      }
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
    final graph = Graph(
      x: position.dx,
      y: position.dy,
      radius: 20.0,
      label: '',
      color: Colors.blue,
      opositeColor: Colors.red,
      type: _pendingGraphType,
    );
    switch (_pendingGraphType) {
      case GraphType.input:
        graph.color = Colors.green;
        graph.label = 'X ${_networkData.getInputGraphsLength() + 1}';
        break;
      case GraphType.perceptron:
        graph.label = 'P ${_networkData.getPerceptronGraphsLegth() + 1}';
        graph.color = Colors.orange;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => BiasInputDialog(
            initialBias: 0.0,
            onBiasSet: (bias) {
              setState(() {
                graph.bias = bias;
              });
            },
            onCancel: () {},
          ),
        );
        break;
      default:
        break;
    }
    setState(() {
      _networkData.graphs.add(graph);
      _networkData.buildInputs();
      _networkData.updatePerceptronValues();
    });
  }

  void _addEdge(Offset position) {
    final graphPosition = _findGraphAtPosition(position);
    if (graphPosition >= 0) {
      final startGraph = _networkData.graphs[_networkData.startingPoint];
      final endGraph = _networkData.graphs[graphPosition];
      //Verificar que no se agregue un edge a si mismo
      if (startGraph == endGraph) {
        _networkData.resetSketch();
        return;
      }
      //Verificar que no exista un edge entre los dos nodos
      for (var edge in _networkData.edges) {
        if ((edge.start == startGraph && edge.end == endGraph) ||
            (edge.start == endGraph && edge.end == startGraph)) {
          _networkData.resetSketch();
          return;
        }
      }
      //Verificar que no se agregue un edge entre dos nodos de tipo input
      if (startGraph.type == GraphType.input &&
          endGraph.type == GraphType.input) {
        _networkData.resetSketch();
        return;
      }
      // Si no existe un edge entre los dos nodos, mostrar el dialogo para ingresar el peso
      showDialog(
        context: context,
        builder: (context) => WeightInputDialog(
          initialWeight: 0.0,
          onWeightSet: (weight) {
            setState(() {
              _networkData.edges.add(
                Edge(
                  start: startGraph,
                  end: endGraph,
                  isSelected: false,
                  color: Colors.black,
                  weight: weight,
                ),
              );
              startGraph.outputsGraphs ??= [];
              endGraph.inputsGraphs ??= [];
              startGraph.outputsGraphs!.add(endGraph);
              endGraph.inputsGraphs!.add(startGraph);
              _networkData.resetStartingPoint();
              _networkData.resetSketch();
            });
          },
          onCancel: () => _networkData.resetSketch(),
        ),
      );
    } else {
      _networkData.resetSketch();
    }
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

  void _addSequence(Offset position) {
    final graphPosition = _findGraphAtPosition(position);
    if (graphPosition >= 0) {
      setState(() {
        if (_networkData.startingPoint == -1) {
          _networkData.startingPoint = graphPosition;
        } else {
          //Validar que el nodo de inicio y el nodo final no sean el mismo
          if (_networkData.startingPoint == graphPosition) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Seleccione nodos diferentes para la secuencia'),
              ),
            );
            return;
          }
          final startGraph = _networkData.graphs[_networkData.startingPoint];
          final endGraph = _networkData.graphs[graphPosition];
          // Validar que exista un edge entre los dos nodos
          Edge? edgeExists;
          for (var edge in _networkData.edges) {
            if ((edge.start == startGraph && edge.end == endGraph) ||
                (edge.start == endGraph && edge.end == startGraph)) {
              edgeExists = edge;
              break;
            }
          }
          if (edgeExists == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Debe haber un edge entre los nodos seleccionados',
                ),
              ),
            );
            return;
          }
          _networkData.sequences.add(
            Sequence(
              start: startGraph,
              end: endGraph,
              section: 0.0,
              edge: edgeExists,
            ),
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
