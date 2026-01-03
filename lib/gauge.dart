import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gauge Component',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const GaugePage(),
    );
  }
}

class GaugePage extends StatefulWidget {
  const GaugePage({super.key});

  @override
  State<GaugePage> createState() => _GaugePageState();
}

class _GaugePageState extends State<GaugePage> {
  double mainGaugeValue = 25;
  final List<double> presetValues = [0, 25, 75, 100];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Gauge',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '\nFramework7 comes with Gauge component. It produces nice looking fully responsive SVG gauges.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            // Main Gauge with Controls
            Center(
              child: Column(
                children: [
                  CircleGauge(
                    value: mainGaugeValue,
                    size: 280,
                    strokeWidth: 20,
                    color: Colors.blue,
                    label: '${mainGaugeValue.toInt()}%',
                    sublabel: 'amount of something',
                  ),
                  const SizedBox(height: 30),
                  // Control Buttons
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: GaugeButton(
                            label: '0%',
                            isSelected: mainGaugeValue == 0,
                            onTap: () => setState(() => mainGaugeValue = 0),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GaugeButton(
                            label: '25%',
                            isSelected: mainGaugeValue == 25,
                            onTap: () => setState(() => mainGaugeValue = 25),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GaugeButton(
                            label: '75%',
                            isSelected: mainGaugeValue == 75,
                            onTap: () => setState(() => mainGaugeValue = 75),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GaugeButton(
                            label: '100%',
                            isSelected: mainGaugeValue == 100,
                            onTap: () => setState(() => mainGaugeValue = 100),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            // Circle Gauges Section
            const Text(
              'Circle Gauges',
              style: TextStyle(
                fontSize: 18,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CircleGauge(
                    value: 44,
                    size: 180,
                    strokeWidth: 16,
                    color: Colors.orange,
                    label: '44%',
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: CircleGauge(
                    value: 12,
                    size: 180,
                    strokeWidth: 16,
                    color: Colors.green,
                    label: '\$120',
                    sublabel: 'of \$1000 budget',
                    sublabelColor: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            // Semicircle Gauges Section
            const Text(
              'Semicircle Gauges',
              style: TextStyle(
                fontSize: 18,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SemicircleGauge(
                    value: 30,
                    size: 180,
                    strokeWidth: 16,
                    color: Colors.red,
                    label: '30%',
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: SemicircleGauge(
                    value: 50,
                    size: 180,
                    strokeWidth: 16,
                    color: Colors.pink,
                    label: '30kg',
                    sublabel: 'of 60kg total',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            // Customization Section
            const Text(
              'Customization',
              style: TextStyle(
                fontSize: 18,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CircleGauge(
                    value: 35,
                    size: 180,
                    strokeWidth: 40,
                    color: Colors.green,
                    backgroundColor: Colors.yellow,
                    label: '35%',
                    labelColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: CircleGauge(
                    value: 67,
                    size: 180,
                    strokeWidth: 40,
                    color: Colors.orange,
                    label: '\$670',
                    labelColor: Colors.black,
                    sublabel: 'of \$1000 spent',
                    sublabelColor: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SemicircleGauge(
                    value: 50,
                    size: 180,
                    strokeWidth: 16,
                    color: Colors.yellow.shade700,
                    label: '50%',
                    labelColor: Colors.yellow.shade700,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: SemicircleGauge(
                    value: 77,
                    size: 180,
                    strokeWidth: 16,
                    color: Colors.orange,
                    label: '\$770 spent so far',
                    labelColor: Colors.orange,
                    labelSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class GaugeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const GaugeButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey[200],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class CircleGauge extends StatelessWidget {
  final double value;
  final double size;
  final double strokeWidth;
  final Color color;
  final Color? backgroundColor;
  final String label;
  final String? sublabel;
  final Color? labelColor;
  final Color? sublabelColor;

  const CircleGauge({
    super.key,
    required this.value,
    required this.size,
    required this.strokeWidth,
    required this.color,
    this.backgroundColor,
    required this.label,
    this.sublabel,
    this.labelColor,
    this.sublabelColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: CircleGaugePainter(
              value: value,
              strokeWidth: strokeWidth,
              color: color,
              backgroundColor: backgroundColor ?? Colors.grey[200]!,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: size * 0.15,
                    fontWeight: FontWeight.bold,
                    color: labelColor ?? color,
                  ),
                ),
                if (sublabel != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      sublabel!,
                      style: TextStyle(
                        fontSize: size * 0.06,
                        color: sublabelColor ?? Colors.grey[600],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CircleGaugePainter extends CustomPainter {
  final double value;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;

  CircleGaugePainter({
    required this.value,
    required this.strokeWidth,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * (value / 100);

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(CircleGaugePainter oldDelegate) =>
      value != oldDelegate.value;
}

class SemicircleGauge extends StatelessWidget {
  final double value;
  final double size;
  final double strokeWidth;
  final Color color;
  final String label;
  final String? sublabel;
  final Color? labelColor;
  final double? labelSize;

  const SemicircleGauge({
    super.key,
    required this.value,
    required this.size,
    required this.strokeWidth,
    required this.color,
    required this.label,
    this.sublabel,
    this.labelColor,
    this.labelSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.6,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(size, size * 0.6),
            painter: SemicircleGaugePainter(
              value: value,
              strokeWidth: strokeWidth,
              color: color,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: labelSize ?? size * 0.13,
                    fontWeight: FontWeight.bold,
                    color: labelColor ?? color,
                  ),
                ),
                if (sublabel != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      sublabel!,
                      style: TextStyle(
                        fontSize: size * 0.06,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SemicircleGaugePainter extends CustomPainter {
  final double value;
  final double strokeWidth;
  final Color color;

  SemicircleGaugePainter({
    required this.value,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, math.pi, math.pi, false, bgPaint);

    // Progress arc
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = math.pi * (value / 100);

    canvas.drawArc(rect, math.pi, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(SemicircleGaugePainter oldDelegate) =>
      value != oldDelegate.value;
}
