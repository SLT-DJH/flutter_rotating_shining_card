import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A widget that displays a 3D rotating card with realistic light reflection effects.
///
/// Supports pan gesture to rotate, snap animation on release,
/// ambient light, specular highlight, fresnel edge glow, rainbow shimmer,
/// and multi-layer touch shine.
class RotatingShiningCard extends StatefulWidget {
  /// The front face widget of the card.
  final Widget frontChild;

  /// The back face widget of the card.
  final Widget backChild;

  /// The width of the card.
  final double width;

  /// The height of the card.
  final double height;

  /// The border radius of the card corners.
  final double borderRadius;

  /// The intensity of all shine effects (0.0 ~ 1.0).
  final double shineIntensity;

  /// The base color of the shine effects.
  final Color shineColor;

  const RotatingShiningCard({
    super.key,
    required this.frontChild,
    required this.backChild,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.shineIntensity = 0.5,
    this.shineColor = Colors.white,
  });

  @override
  RotatingShiningCardState createState() => RotatingShiningCardState();
}

class RotatingShiningCardState extends State<RotatingShiningCard>
    with SingleTickerProviderStateMixin {
  double rotationY = 0.0;
  double rotationX = 0.0;
  Offset shineOffset = Offset.zero;
  bool _isTouching = false;

  double _flipAngle = 0.0;
  late AnimationController _snapController;
  late Animation<double> _snapAnimation;
  double _snapStartAngle = 0.0;
  double _snapTargetAngle = 0.0;
  bool _dragStartedOnBack = false;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _snapController.addListener(() {
      setState(() {
        _flipAngle = _snapStartAngle +
            (_snapTargetAngle - _snapStartAngle) * _snapAnimation.value;
        rotationY = _flipAngle;
      });
    });
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void onTouchMove(Offset localPosition, Offset delta) {
    _snapController.stop();
    setState(() {
      _isTouching = true;

      // ✅ 드래그 시작 시점의 면 기준으로 방향 고정
      final directionFactor = _dragStartedOnBack ? 1.0 : -1.0;
      _flipAngle += directionFactor * delta.dx / widget.width * math.pi;
      rotationY = _flipAngle;

      final centerY = widget.height / 2;
      rotationX = ((localPosition.dy - centerY) / centerY) * (math.pi / 10);
      shineOffset = localPosition;
    });
  }

  void onTouchStart() {
    _dragStartedOnBack = _isBackVisible;
  }

  void onTouchEnd() {
    final nearest = (_flipAngle / math.pi).round() * math.pi;
    _snapStartAngle = _flipAngle;
    _snapTargetAngle = nearest;
    _snapAnimation =
        CurvedAnimation(parent: _snapController, curve: Curves.easeOutCubic);
    _snapController.forward(from: 0);
    setState(() {
      _isTouching = false;
      rotationX = 0.0;
      shineOffset = Offset.zero;
    });
  }

  bool get _isBackVisible {
    final normalized = (_flipAngle / math.pi) % 2;
    final mod = normalized < 0 ? normalized + 2 : normalized;
    return mod >= 0.5 && mod < 1.5;
  }

  double get _tiltX => (rotationX / (math.pi / 10)).clamp(-1.0, 1.0);
  double get _tiltY {
    final nearest = (_flipAngle / math.pi).round() * math.pi;
    final local = rotationY - nearest;
    return (local / (math.pi / 10)).clamp(-1.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(rotationX)
        ..rotateY(rotationY),
      child: GestureDetector(
        onPanStart: (_) => onTouchStart(),
        onPanUpdate: (d) => onTouchMove(d.localPosition, d.delta),
        onPanEnd: (_) => onTouchEnd(),
        onPanCancel: () => onTouchEnd(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: Stack(
              children: [
                if (_isBackVisible)
                  _buildCardFace(child: widget.backChild, rotateY: math.pi),
                if (!_isBackVisible) _buildCardFace(child: widget.frontChild),
                _buildAmbientLight(),
                _buildSpecularHighlight(),
                _buildFresnelEdge(),
                _buildRainbowShimmer(),
                if (shineOffset != Offset.zero) ...[
                  _buildShineLayer(
                      radiusFactor: 1.0, opacity: widget.shineIntensity * 0.15),
                  _buildShineLayer(
                      radiusFactor: 0.4, opacity: widget.shineIntensity * 0.5),
                  _buildShineLayer(
                      radiusFactor: 0.15, opacity: widget.shineIntensity * 0.9),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardFace({required Widget child, double rotateY = 0.0}) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(rotateY),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: child,
      ),
    );
  }

  Widget _buildAmbientLight() {
    final lightX = -0.8 + _tiltY * 0.6;
    final lightY = -0.8 + _tiltX * 0.6;
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(lightX, lightY),
              radius: 1.4,
              colors: [
                widget.shineColor.withOpacity(
                    (0.35 + (_isTouching ? 0.15 : 0.0)) *
                        widget.shineIntensity *
                        2),
                widget.shineColor.withOpacity(0.05 * widget.shineIntensity * 2),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecularHighlight() {
    final tiltMagnitude =
        math.sqrt(_tiltX * _tiltX + _tiltY * _tiltY).clamp(0.0, 1.0);
    if (tiltMagnitude < 0.05) return const SizedBox.shrink();

    final specX = (-0.8 + _tiltY * 1.2).clamp(-1.0, 1.0);
    final specY = (-0.8 + _tiltX * 1.2).clamp(-1.0, 1.0);
    final posLeft = (specX + 1) / 2 * widget.width;
    final posTop = (specY + 1) / 2 * widget.height;
    final r = widget.width * 0.25;

    return Positioned(
      left: posLeft - r,
      top: posTop - r,
      child: IgnorePointer(
        child: Container(
          width: r * 2,
          height: r * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.white.withOpacity(
                    (tiltMagnitude * 0.7 * widget.shineIntensity)
                        .clamp(0.0, 0.8)),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFresnelEdge() {
    final tiltMagnitude =
        math.sqrt(_tiltX * _tiltX + _tiltY * _tiltY).clamp(0.0, 1.0);
    final opacity =
        (tiltMagnitude * widget.shineIntensity * 0.6).clamp(0.0, 0.6);
    if (opacity < 0.02) return const SizedBox.shrink();

    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-_tiltY, -_tiltX),
              end: Alignment(_tiltY * 0.5, _tiltX * 0.5),
              colors: [
                Colors.white.withOpacity(opacity),
                Colors.transparent,
              ],
              stops: const [0.0, 0.45],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRainbowShimmer() {
    final tiltMagnitude =
        math.sqrt(_tiltX * _tiltX + _tiltY * _tiltY).clamp(0.0, 1.0);
    final opacity =
        (tiltMagnitude * widget.shineIntensity * 0.25).clamp(0.0, 0.3);
    if (opacity < 0.02) return const SizedBox.shrink();

    final angle = math.atan2(_tiltX, _tiltY);

    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: SweepGradient(
              center: Alignment.center,
              startAngle: angle,
              endAngle: angle + math.pi,
              colors: [
                Colors.red.withOpacity(opacity),
                Colors.orange.withOpacity(opacity),
                Colors.yellow.withOpacity(opacity),
                Colors.green.withOpacity(opacity),
                Colors.blue.withOpacity(opacity),
                Colors.purple.withOpacity(opacity),
                Colors.red.withOpacity(opacity),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShineLayer({
    required double radiusFactor,
    required double opacity,
  }) {
    final r = widget.width * radiusFactor;
    return Positioned(
      left: shineOffset.dx - r,
      top: shineOffset.dy - r,
      child: IgnorePointer(
        child: Container(
          width: r * 2,
          height: r * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                widget.shineColor.withOpacity(opacity.clamp(0.0, 1.0)),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
