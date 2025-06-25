import 'package:flutter/material.dart';
import 'package:project_2_graphs/data/models/home/network_data.dart';
import 'package:project_2_graphs/data/paints/home/cartesian_plane_painter.dart';

class CartesianPlaneWidget extends StatefulWidget {
  final NetworkData networkData;
  const CartesianPlaneWidget({super.key, required this.networkData});

  @override
  State<CartesianPlaneWidget> createState() => _CartesianPlaneWidgetState();
}

class _CartesianPlaneWidgetState extends State<CartesianPlaneWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Epoca ${widget.networkData.currentEpoch}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Container(
          height: 250,
          width: double.infinity,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomPaint(
            painter: CartesianPlanePainter(networkData: widget.networkData),
            child: Container(),
          ),
        ),
      ],
    );
  }
}
