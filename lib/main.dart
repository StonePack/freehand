import 'package:flutter/material.dart';

class BrushStroke {
  BrushStroke({required this.paint, required this.path});

  Paint paint;
  List<Offset> path;
}

void main() {
  runApp(const DrawingApp());
}

class DrawingApp extends StatelessWidget {
  const DrawingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawing Canvas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DrawingCanvas(),
    );
  }
}

class DrawingCanvas extends StatefulWidget {
  const DrawingCanvas({super.key});

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  List<BrushStroke> brushStrokes = [];

  Paint brush = Paint();

  _onBrushStrokeStart(Offset position) {
    BrushStroke newStroke = BrushStroke(
      paint: brush,
      path: [
        position,
      ],
    );

    setState(() {
      brushStrokes.add(newStroke);
    });
  }

  _onBrushStrokeUpdate(Offset position) {
    setState(() {
      brushStrokes.last.path.add(position);
    });
  }

  @override
  void initState() {
    brush.strokeCap = StrokeCap.round;
    brush.strokeWidth = 5;
    brush.color = const Color(0xFFFCD581);
    brush.style = PaintingStyle.stroke;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF242423),
      body: GestureDetector(
        onPanStart: (DragStartDetails details) {
          _onBrushStrokeStart(details.localPosition);
        },
        onPanUpdate: (DragUpdateDetails details) {
          _onBrushStrokeUpdate(details.localPosition);
        },
        child: CustomPaint(
          painter: DrawingPainter(brushStrokes: brushStrokes),
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height,
            width: MediaQuery.sizeOf(context).width,
          ),
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  DrawingPainter({required this.brushStrokes});

  List<BrushStroke> brushStrokes;

  @override
  void paint(Canvas canvas, Size size) {
    for (BrushStroke stroke in brushStrokes) {
      Path path = Path();
      path.moveTo(stroke.path[0].dx, stroke.path[0].dy);

      if (stroke.path.length == 1) {
        path.close();
      } else {
        for (var i = 1; i < stroke.path.length - 1; i++) {
          path.lineTo(stroke.path[i].dx, stroke.path[i].dy);
        }
      }

      canvas.drawPath(path, stroke.paint);
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) {
    return true;
  }
}
