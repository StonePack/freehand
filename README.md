# freehand

This is a lab project to find the cleanest/simplist way to handle free form drawing using a CustomPainter. No external packages needed!

There's a lot of examples online but felt that this could still be useful for anyone still looking.

## Project Findings

### Abstract
Using the `Path` class I found to be the easiest method for drawing the user generated brush strokes. It's fairly easy to update a path within the gesture detector `onUpdate` methods by tracking the `Offset` positions and requires minimal code to draw in a custom painter.

Additionally, creating a custom class that stores a `List<Offset>` and `Paint` instance makes it simple to store user selected brush options and the path offsets generated using the gestureDetector for individual strokes.

### Implementation
First, start by creating a class that has a `List<Offset>` which will be used to generate the path in the `CustomPainter` later and `Paint` properties:

```dart
class BrushStroke {
  BrushStroke({required this.paint, required this.path});

  Paint paint;
  List<Offset> path;
}
```

Next, you'll need to create a `GestureDetector` and a `CustomPaint` widget in a stateful widget:

```dart
List<BrushStroke> brushStrokes = [];

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFF242423),
    body: GestureDetector(
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
```

The `brushStrokes` variable is used to store each of the brush strokes. To paint these brush strokes to the canvas, we need to create a custom painter, in this case we'll call it `DrawingPainter`:

```dart
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
```

In the `paint` method, we iterate through each of the users brush strokes. For each `BrushStroke` we use the list of offsets to generate a path, only closing the path if there's a single point. This allows us to paint a single point if the user just taps on our drawing canvas. We also utilize the paint options stored with the brush stroke so we can draw in different path sizes and colors.

Finally, we implement a way to capture the users gestures. This can be done with the `onPanStart` and `onPanUpdate` methods of the previously added `GestureDetector` and passing the `possition.offset` to our utility methods:

```dart
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
```

To see a full implementation, check out the code in `lib/main.dart`.

### Improvements
There's defnitely room for improvement. For instance, perhaps creating a stack of custom painters where each one handles a brush stroke to prevent repainting every time a user makes a new brush stroke.

Additionally, I want to do more research into erasing only parts of brush strokes and creating a scalable and panable canvas.
