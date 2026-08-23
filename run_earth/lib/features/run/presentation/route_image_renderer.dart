import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/models/geo.dart';
import 'route_painter.dart';

/// 커버 이미지 한 변 크기(px). 정사각형 PNG로 저장한다.
const double _coverSize = 1080;

/// 추적된 [route] 를 네온그린 경로 PNG 로 렌더해 앱 문서 폴더에 저장하고
/// 파일 경로를 돌려준다. 좌표가 2개 미만이면 렌더 불가 → null.
/// (run-flow.md 7: 포인트 부족 시 대체 이미지 정책은 미확정 → 일단 빈값)
Future<String?> renderRouteCover(List<LatLngPoint> route, {String? id}) async {
  if (route.length < 2) return null;

  const size = Size(_coverSize, _coverSize);
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  RoutePainter(route: route).paint(canvas, size);
  final picture = recorder.endRecording();

  final image = await picture.toImage(size.width.toInt(), size.height.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  picture.dispose();
  image.dispose();
  if (bytes == null) return null;

  final dir = await getApplicationDocumentsDirectory();
  final name = 'route_${id ?? DateTime.now().millisecondsSinceEpoch}.png';
  final file = File('${dir.path}${Platform.pathSeparator}$name');
  await file.writeAsBytes(bytes.buffer.asUint8List());
  return file.path;
}
