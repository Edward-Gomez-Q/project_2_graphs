enum OperationMod {
  notSelected(-1),
  addGraph(1),
  moveGraph(5),
  deleteAll(2),
  addEdge(3),
  addSequence(4),

  training(6);

  const OperationMod(this.value);

  final int value;
}
