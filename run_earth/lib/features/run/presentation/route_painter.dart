import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/models/geo.dart';
import '../../../core/theme/app_colors.dart';

/// GPS 경로를 어두운 배경 위 네온그린 라인으로 그린다.
/// 지도 타일 없이 라인만 — run-flow.md 3장(대표 이미지 = 경로 렌더) 정본.
/// 러닝 중 실시간 화면과 종료 후 커버 이미지 생성에 공용으로 쓴다.
class RoutePainter extends CustomPainter {
  RoutePainter({
    required this.route,
    this.background = const Color(0xFF070911),
    this.line = AppColors.primary,
    this.showEndpoints = true,
  });

  final List<LatLngPoint> route;
  final Color background;
  final Color line;
  final bool showEndpoints;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    if (route.length < 2) return;

    final points = _project(size);

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }

    // 네온 글로우(흐림) → 선명한 라인 순서로 겹쳐 그린다.
    final glow = Paint()
      ..color = line.withAlpha(0x66)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.03
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.shortestSide * 0.012);
    canvas.drawPath(path, glow);

    final stroke = Paint()
      ..color = line
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.011
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, stroke);

    if (showEndpoints) {
      final r = size.shortestSide * 0.016;
      // 시작점: 흰 테두리 원
      canvas.drawCircle(
        points.first,
        r,
        Paint()..color = Colors.white,
      );
      // 끝점: 네온그린 원
      canvas.drawCircle(points.last, r, Paint()..color = line);
    }
  }

  /// 위경도 → 캔버스 좌표. 경도는 위도 보정(cos)해 종횡비 왜곡을 줄이고,
  /// 여백을 두고 화면에 꽉 차게(aspect-fit) 배치한다.
  List<Offset> _project(Size size) {
    var minLat = route.first.lat, maxLat = route.first.lat;
    var minLng = route.first.lng, maxLng = route.first.lng;
    for (final p in route) {
      minLat = math.min(minLat, p.lat);
      maxLat = math.max(maxLat, p.lat);
      minLng = math.min(minLng, p.lng);
      maxLng = math.max(maxLng, p.lng);
    }

    final midLat = (minLat + maxLat) / 2;
    final cosLat = math.cos(midLat * math.pi / 180).abs();

    final spanX = ((maxLng - minLng) * cosLat).abs();
    final spanY = (maxLat - minLat).abs();

    final padding = size.shortestSide * 0.14;
    final availW = size.width - padding * 2;
    final availH = size.height - padding * 2;

    // 한 축의 이동이 없으면(직선) 0으로 나누지 않도록 보정.
    final scaleX = spanX < 1e-9 ? double.infinity : availW / spanX;
    final scaleY = spanY < 1e-9 ? double.infinity : availH / spanY;
    var scale = math.min(scaleX, scaleY);
    if (!scale.isFinite) scale = 1; // 점들이 사실상 한 지점에 몰린 경우

    final drawW = spanX * scale;
    final drawH = spanY * scale;
    final offX = (size.width - drawW) / 2;
    final offY = (size.height - drawH) / 2;

    return route.map((p) {
      final x = (p.lng - minLng) * cosLat * scale + offX;
      // 위도가 클수록 위쪽(y 작게) — 화면 좌표계로 뒤집는다.
      final y = (maxLat - p.lat) * scale + offY;
      return Offset(x, y);
    }).toList();
  }

  @override
  bool shouldRepaint(covariant RoutePainter old) =>
      old.route != route || old.line != line || old.background != background;
}
