import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/app_services.dart';

class DrawingGameScreen extends StatefulWidget {
  const DrawingGameScreen(this.services, {super.key});
  final AppServices services;
  @override State<DrawingGameScreen> createState() => _DrawingGameScreenState();
}

class _DrawingGameScreenState extends State<DrawingGameScreen> {
  final strokes = <DrawStroke>[];
  Color color = Colors.purple;
  double width = 10;
  bool started = false;

  void addPoint(Offset? point) {
    if (!started) { started = true; widget.services.analytics.track('drawing_started', gameId: 'drawing_game'); }
    setState(() => strokes.add(DrawStroke(point, color, width)));
  }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(leading: const BackButton(), title: const Text('🎨'), actions: [IconButton(tooltip: 'Limpiar', onPressed: () { HapticFeedback.mediumImpact(); setState(strokes.clear); }, icon: const Icon(Icons.delete_sweep))]),
    body: SafeArea(child: Column(children: [
      Expanded(child: Container(margin: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)]), clipBehavior: Clip.antiAlias, child: GestureDetector(behavior: HitTestBehavior.opaque, onPanStart: (d) => addPoint(d.localPosition), onPanUpdate: (d) => addPoint(d.localPosition), onPanEnd: (_) => addPoint(null), child: CustomPaint(painter: DrawingPainter(strokes), size: Size.infinite)))),
      Container(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12), child: Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, spacing: 12, children: [
        for (final option in [Colors.purple, Colors.red, Colors.orange, Colors.green, Colors.blue, Colors.black, Colors.white]) GestureDetector(onTap: () => setState(() => color = option), child: AnimatedContainer(duration: const Duration(milliseconds: 120), width: color == option ? 58 : 50, height: color == option ? 58 : 50, decoration: BoxDecoration(color: option, shape: BoxShape.circle, border: Border.all(color: option == Colors.white ? Colors.grey : color == option ? Colors.yellow : Colors.white, width: 5)))),
        IconButton(onPressed: () => setState(() => width = width == 10 ? 24 : 10), icon: Icon(width == 10 ? Icons.brush : Icons.circle)),
      ])),
    ])),
  );
}

class DrawStroke { const DrawStroke(this.point, this.color, this.width); final Offset? point; final Color color; final double width; }
class DrawingPainter extends CustomPainter {
  DrawingPainter(this.strokes); final List<DrawStroke> strokes;
  @override void paint(Canvas canvas, Size size) {
    for (var i = 0; i < strokes.length - 1; i++) { final a = strokes[i], b = strokes[i + 1]; if (a.point != null && b.point != null) canvas.drawLine(a.point!, b.point!, Paint()..color = a.color..strokeWidth = a.width..strokeCap = StrokeCap.round); }
  }
  @override bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

