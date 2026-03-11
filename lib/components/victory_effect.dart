import 'package:flutter/material.dart';
import 'dart:math';

class VictoryEffect extends StatefulWidget {
  const VictoryEffect({super.key});

  @override
  State<VictoryEffect> createState() => _VictoryEffectState();
}

class _VictoryEffectState extends State<VictoryEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500), // พลุจะกระจายอยู่ 2.5 วินาที
    );

    // สร้างเศษพลุ 120 ชิ้น
    for (int i = 0; i < 120; i++) {
      _particles.add(_Particle(
        color: _getRandomColor(),
        x: 0.5, // จุดเริ่มต้น X (ตรงกลาง)
        y: 0.3, // จุดเริ่มต้น Y (ค่อนไปทางบนนิดนึง จะได้หล่นลงมาสวยๆ)
        angle: _random.nextDouble() * 2 * pi, // ทิศทางกระจาย 360 องศา
        speed: _random.nextDouble() * 20 + 5, // ความเร็วในการพุ่ง
        size: _random.nextDouble() * 8 + 4,   // ขนาดชิ้นพลุ
        rotation: _random.nextDouble() * 2 * pi,
      ));
    }

    _controller.addListener(() => setState(() {}));
    _controller.forward(); // สั่งเล่นแอนิเมชันทันทีที่เปิดขึ้นมา
  }

  Color _getRandomColor() {
    List<Color> colors = [
      Colors.green, Colors.blue, Colors.pinkAccent,
      Colors.orange, Colors.purpleAccent, Colors.yellow, Colors.cyan
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ใชั IgnorePointer เพื่อให้ผู้เล่นสามารถเอานิ้วทะลุไปกดปุ่มด้านหลังได้
    return IgnorePointer(
      child: CustomPaint(
        painter: _ConfettiPainter(_particles, _controller.value),
        child: Container(), // ใช้พื้นที่ให้เต็มจอ
      ),
    );
  }
}

class _Particle {
  Color color;
  double x, y, angle, speed, size, rotation;

  _Particle({
    required this.color, required this.x, required this.y,
    required this.angle, required this.speed, required this.size, required this.rotation,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ConfettiPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var p in particles) {
      // คำนวณระยะทางและแรงโน้มถ่วง
      double distance = p.speed * progress * 30; // พุ่งออกไป
      double gravity = progress * progress * 500; // ตกลงมาด้านล่าง

      double px = (size.width * p.x) + (cos(p.angle) * distance);
      double py = (size.height * p.y) + (sin(p.angle) * distance) + gravity;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation + (progress * 15)); // หมุนติ้วๆ ระหว่างร่วง

      paint.color = p.color.withOpacity(1.0 - progress); // ค่อยๆ จางหายไปตอนท้าย

      // สุ่มวาดสี่เหลี่ยมบ้าง วงกลมบ้าง
      if (p.size % 2 > 1) {
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size), paint);
      } else {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
