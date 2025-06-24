enum OperationMod {
  notSelected(-1),
  addGraph(1),
  deleteAll(2),
  addEdge(3),
  addSequence(4);

  const OperationMod(this.value);

  final int value;
}
