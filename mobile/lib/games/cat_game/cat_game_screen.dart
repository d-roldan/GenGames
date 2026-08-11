import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/app_services.dart';

class CatGameScreen extends StatefulWidget {
  const CatGameScreen(this.services, {super.key});
  final AppServices services;
  @override
  State<CatGameScreen> createState() => _CatGameScreenState();
}

class _CatGameScreenState extends State<CatGameScreen> with SingleTickerProviderStateMixin {
  String mood = 'happy';
  late final AnimationController animation = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));

  void react(String interaction) {
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);
    widget.services.analytics.track('cat_interaction', gameId: 'cat_game', metadata: {'interaction': interaction});
    setState(() => mood = interaction == 'bed' ? 'sleeping' : interaction == 'food' ? 'eating' : 'happy');
    animation.forward(from: 0);
  }

  @override
  void dispose() { animation.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(leading: const BackButton(), title: const Text('🐱')),
        body: SafeArea(child: Column(children: [
          Expanded(child: Center(child: AnimatedBuilder(animation: animation, builder: (_, __) => Transform.rotate(angle: mood == 'sleeping' ? 0 : math.sin(animation.value * math.pi * 2) * .035, child: SizedBox(width: 330, height: 360, child: Stack(children: [
            Positioned.fill(child: DragTarget<String>(onAcceptWithDetails: (details) => react(details.data), builder: (_, __, ___) => CustomPaint(painter: CatPainter(mood: mood)))),
            Positioned(left: 95, top: 35, width: 140, height: 105, child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: () => react('head'))),
            Positioned(left: 82, top: 140, width: 175, height: 150, child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: () => react('belly'))),
            Positioned(right: 4, top: 178, width: 80, height: 100, child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: () => react('tail'))),
          ]))))),
          Padding(padding: const EdgeInsets.all(22), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _CatObject(icon: '🐟', label: 'food', onTap: () => react('food')),
            _CatObject(icon: '🧶', label: 'toy', onTap: () => react('toy')),
            _CatObject(icon: '🛏️', label: 'bed', onTap: () => react('bed')),
          ])),
        ])),
      );
}

class _CatObject extends StatelessWidget {
  const _CatObject({required this.icon, required this.label, required this.onTap});
  final String icon, label; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Draggable<String>(data: label, feedback: Material(color: Colors.transparent, child: Text(icon, style: const TextStyle(fontSize: 70))), childWhenDragging: const SizedBox(width: 76, height: 76), child: InkWell(borderRadius: BorderRadius.circular(24), onTap: onTap, child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black12)]), child: Text(icon, style: const TextStyle(fontSize: 56)))));
}

class CatPainter extends CustomPainter {
  CatPainter({required this.mood});
  final String mood;
  @override
  void paint(Canvas canvas, Size size) {
    final fur = Paint()..color = const Color(0xFFFFA94D);
    final dark = Paint()..color = const Color(0xFF5D4037)..strokeWidth = 7..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * .5, size.height * .61), width: 185, height: 195), fur);
    canvas.drawCircle(Offset(size.width * .5, size.height * .28), 72, fur);
    final ear = Path()..moveTo(105, 72)..lineTo(120, 5)..lineTo(157, 61)..close(); canvas.drawPath(ear, fur);
    final ear2 = Path()..moveTo(225, 72)..lineTo(210, 5)..lineTo(173, 61)..close(); canvas.drawPath(ear2, fur);
    canvas.drawArc(Rect.fromLTWH(222, 180, 95, 125), -1.3, 3.2, false, dark);
    if (mood == 'sleeping') {
      canvas.drawArc(Rect.fromLTWH(126, 84, 28, 15), 0, math.pi, false, dark); canvas.drawArc(Rect.fromLTWH(177, 84, 28, 15), 0, math.pi, false, dark);
    } else {
      canvas.drawCircle(const Offset(141, 94), 7, Paint()..color = Colors.black); canvas.drawCircle(const Offset(190, 94), 7, Paint()..color = Colors.black);
    }
    canvas.drawCircle(const Offset(165, 118), 5, Paint()..color = Colors.pinkAccent);
    canvas.drawArc(Rect.fromLTWH(146, 114, 38, 28), 0, math.pi, false, dark);
    if (mood == 'sleeping') { final text = TextPainter(text: const TextSpan(text: 'Z z', style: TextStyle(fontSize: 34, color: Colors.indigo, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)..layout(); text.paint(canvas, const Offset(245, 50)); }
  }
  @override
  bool shouldRepaint(CatPainter oldDelegate) => mood != oldDelegate.mood;
}

