import 'dart:math' as math;

/// 기상청 단기예보 격자 좌표. API 는 위경도가 아니라 이 (nx, ny) 를 받는다.
class KmaGrid {
  const KmaGrid(this.nx, this.ny);

  final int nx;
  final int ny;

  @override
  bool operator ==(Object other) =>
      other is KmaGrid && other.nx == nx && other.ny == ny;

  @override
  int get hashCode => Object.hash(nx, ny);

  @override
  String toString() => 'KmaGrid($nx, $ny)';
}

/// 위경도 → 기상청 격자. 람베르트 정각원추도법(LCC), 격자 간격 5km.
///
/// 상수와 식은 기상청이 단기예보 조회서비스 활용가이드에 공개한 변환 코드
/// 그대로다. 서울시청(37.5665, 126.9780)이 (60, 127) 로 나오는지가 검증 기준.
KmaGrid toKmaGrid(double lat, double lng) {
  const re = 6371.00877; // 지구 반경(km)
  const grid = 5.0; // 격자 간격(km)
  const slat1 = 30.0; // 투영 위도1
  const slat2 = 60.0; // 투영 위도2
  const olon = 126.0; // 기준점 경도
  const olat = 38.0; // 기준점 위도
  const xo = 43.0; // 기준점 X 격자
  const yo = 136.0; // 기준점 Y 격자
  const degrad = math.pi / 180.0;

  final r = re / grid;
  final s1 = slat1 * degrad;
  final s2 = slat2 * degrad;
  final lon0 = olon * degrad;
  final lat0 = olat * degrad;

  var sn = math.tan(math.pi * 0.25 + s2 * 0.5) / math.tan(math.pi * 0.25 + s1 * 0.5);
  sn = math.log(math.cos(s1) / math.cos(s2)) / math.log(sn);
  var sf = math.tan(math.pi * 0.25 + s1 * 0.5);
  sf = math.pow(sf, sn) * math.cos(s1) / sn;
  var ro = math.tan(math.pi * 0.25 + lat0 * 0.5);
  ro = r * sf / math.pow(ro, sn);

  var ra = math.tan(math.pi * 0.25 + lat * degrad * 0.5);
  ra = r * sf / math.pow(ra, sn);
  var theta = lng * degrad - lon0;
  if (theta > math.pi) theta -= 2.0 * math.pi;
  if (theta < -math.pi) theta += 2.0 * math.pi;
  theta *= sn;

  final x = (ra * math.sin(theta) + xo + 0.5).floor();
  final y = (ro - ra * math.cos(theta) + yo + 0.5).floor();
  return KmaGrid(x, y);
}
