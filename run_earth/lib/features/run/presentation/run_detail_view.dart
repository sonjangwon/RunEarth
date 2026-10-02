import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/geo.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/storage/cover_storage.dart';
import '../data/km_splits.dart';
import 'route_painter.dart';

/// 닫기 버튼 모양. 기능정의서 5 `RunDetailView.closeIcon`.
enum RunDetailClose {
  /// 막 끝낸 러닝(달리기 탭) — 닫으면 prerun 으로 초기화.
  x,

  /// 기록 탭에서 들어온 상세 — 닫으면 목록으로 복귀.
  back,
}

/// 러닝 결과 / 기록 상세 공용 화면 (기능정의서 5 `RunDetailView`).
///
/// 두 화면은 **같은 컴포넌트**다. 달라지는 건 닫기 버튼과 아래에 덧붙는
/// 내용뿐이라 [closeIcon] 과 [footer] 로 갈린다.
///
/// 레이아웃 정본은 Figma(App.tsx 423-639) — **4:5 히어로 카드**가 중심이다.
/// 경로를 화면 가득 보여주고 수치를 그 위에 얹는 구성으로, 그대로 공유해도
/// 되는 한 장이 되게 했다(워터마크가 그래서 있다).
///
/// 대표 이미지는 저장된 PNG 를 읽지 않고 **[route] 좌표로 직접 그린다.**
/// 좌표만 있으면 어디서든 다시 그릴 수 있고(2026-09-11 결정), 렌더가 실패했거나
/// 파일이 사라진 기록도 정상적으로 보인다.
///
/// 사진이 있으면 **사진 모드**(Strava 식 — 사진 배경 + 왼쪽 세로 수치),
/// 없으면 **경로 모드**(다크맵 + 격자 + 네온 글로우 + 중앙 경로)로 그린다.
/// 2026-09-23 에 사진 모드가 붙어 둘 다 있다.
class RunDetailView extends StatelessWidget {
  const RunDetailView({
    super.key,

    /// 워터마크에 찍히는 날짜 — `2026.09.23` (`RUN EARTH · {dateLabel}`).
    ///
    /// **이 값이 쓰이는 곳은 워터마크뿐이다.** 예전 이름이 `title` 이었는데
    /// 그 탓에 달리기 결과 화면이 `'러닝 완료'` 를 넘겨 워터마크가
    /// `RUN EARTH · 러닝 완료` 로 찍히고 있었다(2026-09-25 발견).
    ///
    /// 연도를 붙이는 이유: 워터마크는 **앱 밖으로 나가는 문구**다. 공유한
    /// 사진을 나중에 볼 때 필요한 건 연도이고, 요일은 앱 안 기록 카드에
    /// 이미 있다. Figma 정본도 `2026.{date}` 다.
    required this.dateLabel,
    required this.route,
    required this.durStr,
    required this.distanceStr,
    required this.paceStr,
    required this.kcal,
    required this.onClose,
    this.closeIcon = RunDetailClose.back,
    this.headerTrailing,
    this.footer,
    this.photoPath,
    this.onPickPhoto,
  });

  final String dateLabel;
  final List<LatLngPoint> route;
  final String durStr;
  final String distanceStr;
  final String paceStr;
  final int kcal;
  final VoidCallback onClose;
  final RunDetailClose closeIcon;

  /// 상단 줄 오른쪽에 붙는 것(러닝 타입·동기화 대기 뱃지 등).
  final Widget? headerTrailing;

  /// 수치 카드 아래에 붙는 것(완료 버튼·안내 문구 등).
  final Widget? footer;

  /// 등록된 대표 사진의 로컬 경로. 있으면 히어로가 **사진 모드**가 된다
  /// (`run-flow.md` 6 `coverImageType: photo`).
  final String? photoPath;

  /// 사진 등록·변경을 누를 때. null 이면 카메라 버튼 자체를 안 그린다 —
  /// 아직 배선되지 않은 화면에서 눌리지 않는 버튼이 생기지 않게.
  final VoidCallback? onPickPhoto;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Hero(
            dateLabel: dateLabel,
            route: route,
            durStr: durStr,
            distanceStr: distanceStr,
            paceStr: paceStr,
            kcal: kcal,
            onClose: onClose,
            closeIcon: closeIcon,
            headerTrailing: headerTrailing,
            photoPath: photoPath,
            onPickPhoto: onPickPhoto,
          ),
          const SizedBox(height: 16),
          _SectionLabel('상세 기록'),
          const SizedBox(height: 10),
          _DetailGrid(
            distanceStr: distanceStr,
            paceStr: paceStr,
            durStr: durStr,
            kcal: kcal,
          ),
          const SizedBox(height: 18),
          _SectionLabel('달린 구간'),
          const SizedBox(height: 8),
          _RouteSection(route: route),
          // 구간별 페이스 — 좌표에 시간이 없는 예전 기록에서는 통째로 빠진다.
          _SplitsSection(route: route),
          // 기록 수치는 읽기 전용이다. 수정·삭제 UI 는 두지 않는다
          // (records.md 4 — 버튼 자체를 만들지 않는 것이 정책).
          if (footer != null) ...[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: footer!,
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// 4:5 히어로 — 다크맵 배경 + 그리드 + 네온 글로우 + 중앙 경로 + 하단 수치.
class _Hero extends StatelessWidget {
  const _Hero({
    required this.dateLabel,
    required this.route,
    required this.durStr,
    required this.distanceStr,
    required this.paceStr,
    required this.kcal,
    required this.onClose,
    required this.closeIcon,
    this.headerTrailing,
    this.photoPath,
    this.onPickPhoto,
  });

  final String dateLabel;
  final List<LatLngPoint> route;
  final String durStr;
  final String distanceStr;
  final String paceStr;
  final int kcal;
  final VoidCallback onClose;
  final RunDetailClose closeIcon;
  final Widget? headerTrailing;
  final String? photoPath;
  final VoidCallback? onPickPhoto;

  @override
  Widget build(BuildContext context) {
    final isBack = closeIcon == RunDetailClose.back;

    return AspectRatio(
      // 4:5 — 그대로 공유할 수 있는 인스타 비율(Figma 488줄).
      aspectRatio: 4 / 5,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 사진이 있으면 사진 모드(Strava 식), 없으면 경로 모드.
          if (photoPath == null)
            _RouteHeroBody(
              route: route,
              durStr: durStr,
              distanceStr: distanceStr,
              paceStr: paceStr,
              kcal: kcal,
              dateLabel: dateLabel,
            )
          else
            _PhotoHeroBody(
              photoPath: photoPath!,
              durStr: durStr,
              distanceStr: distanceStr,
              paceStr: paceStr,
              route: route,
              dateLabel: dateLabel,
            ),
          // 상단 오버레이 — 닫기 + 뱃지.
          Positioned(
            left: 12,
            right: 12,
            top: 10,
            child: Row(
              children: [
                _RoundIconButton(
                  icon: isBack ? Icons.arrow_back : Icons.close,
                  tooltip: isBack ? '기록 목록으로' : '닫기',
                  onTap: onClose,
                ),
                const Spacer(),
                ?headerTrailing,
                // 사진 등록·변경(Figma 451-460). 뱃지 오른쪽 끝에 둔다.
                if (onPickPhoto != null) ...[
                  if (headerTrailing != null) const SizedBox(width: 6),
                  _RoundIconButton(
                    icon: Icons.photo_camera_outlined,
                    tooltip: photoPath == null ? '사진 등록' : '사진 변경',
                    onTap: onPickPhoto!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 히어로 위 반투명 원형 버튼(Figma 437-450).
class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withAlpha(0x80),
            border: Border.all(color: Colors.white.withAlpha(0x26)),
          ),
          child: Icon(icon, size: 17, color: AppColors.foreground),
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value, this.unit});

  final String label;
  final String value;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: AppTextStyles.mono(
                fontSize: 8, color: Colors.white.withAlpha(0x66))),
        const SizedBox(height: 3),
        RichText(
          text: TextSpan(
            text: value,
            style: AppTextStyles.display(fontSize: 20),
            children: [
              if (unit != null)
                TextSpan(
                    text: ' $unit',
                    style: AppTextStyles.sans(
                        fontSize: 9, color: Colors.white.withAlpha(0x73))),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroDivider extends StatelessWidget {
  const _HeroDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      color: Colors.white.withAlpha(0x1F),
    );
  }
}

/// 히어로 배경 격자.
class _HeroGridPainter extends CustomPainter {
  const _HeroGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(0x08)
      ..strokeWidth = 1;
    const rows = 9;
    const cols = 7;
    for (var i = 1; i < rows; i++) {
      final y = size.height / rows * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (var i = 1; i < cols; i++) {
      final x = size.width / cols * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeroGridPainter oldDelegate) => false;
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(text,
          style: AppTextStyles.mono(
              fontSize: 10, color: AppColors.mutedForeground)),
    );
  }
}

/// 상세 기록 6칸(Figma 585-601).
///
/// 평균 심박수·케이던스는 **웨어러블 데이터**라 아직 값이 없다
/// (`wearable-sync.md`, MVP 이후). 칸을 지우지 않고 `--` 로 둔다 —
/// 칼로리가 이미 같은 방식이고, 자리를 비워두면 연동됐을 때 레이아웃이 흔들린다.
class _DetailGrid extends StatelessWidget {
  const _DetailGrid({
    required this.distanceStr,
    required this.paceStr,
    required this.durStr,
    required this.kcal,
  });

  final String distanceStr;
  final String paceStr;
  final String durStr;
  final int kcal;

  @override
  Widget build(BuildContext context) {
    final cells = <({String label, String value, String unit})>[
      (label: '총 거리', value: distanceStr, unit: 'km'),
      (label: '평균 페이스', value: paceStr, unit: '/km'),
      (label: '시간', value: durStr, unit: ''),
      (label: '칼로리', value: kcal > 0 ? '$kcal' : '--', unit: 'kcal'),
      (label: '평균 심박수', value: '--', unit: 'bpm'),
      (label: '케이던스', value: '--', unit: 'spm'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (var row = 0; row < 2; row++) ...[
            if (row > 0) const SizedBox(height: 8),
            // Row 를 세로로 stretch 하면 스크롤뷰 안에서 높이가 무한이 되어
            // 레이아웃이 터진다. 칸 높이를 맞추는 건 IntrinsicHeight 가 한다.
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var col = 0; col < 3; col++) ...[
                    if (col > 0) const SizedBox(width: 8),
                    Expanded(child: _cell(cells[row * 3 + col])),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _cell(({String label, String value, String unit}) c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(c.label,
                style: AppTextStyles.sans(
                    fontSize: 9, color: AppColors.mutedForeground)),
            const SizedBox(height: 5),
            RichText(
              text: TextSpan(
                text: c.value,
                style: AppTextStyles.display(fontSize: 18),
                children: [
                  if (c.unit.isNotEmpty)
                    TextSpan(
                        text: ' ${c.unit}',
                        style: AppTextStyles.sans(
                            fontSize: 8, color: AppColors.mutedForeground)),
                ],
              ),
            ),
          ],
        ),
      );
}

/// '구간별 페이스' — 1km 마다 얼마나 걸렸나. 막대는 **빠를수록 길다**(Figma).
///
/// 좌표에 시간이 없는 기록(2026-09-21 이전)에서는 계산이 안 되므로
/// **섹션째 그리지 않는다** — 빈 카드를 남기면 고장난 것처럼 보인다.
class _SplitsSection extends StatelessWidget {
  const _SplitsSection({required this.route});

  final List<LatLngPoint> route;

  @override
  Widget build(BuildContext context) {
    final splits = computeKmSplits(route);
    if (splits.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 18),
        _SectionLabel('구간별 페이스'),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              for (var i = 0; i < splits.length; i++) ...[
                if (i > 0)
                  const Divider(height: 1, color: AppColors.border),
                _SplitRow(split: splits[i], ratio: splitBarRatio(splits[i], splits)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SplitRow extends StatelessWidget {
  const _SplitRow({required this.split, required this.ratio});

  final KmSplit split;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 46,
            child: RichText(
              text: TextSpan(
                text: split.kmLabel,
                style: AppTextStyles.mono(
                    fontSize: 10, color: AppColors.mutedForeground),
                children: [
                  TextSpan(
                      text: ' km',
                      style: AppTextStyles.mono(
                          fontSize: 8, color: AppColors.mutedForeground)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                height: 6,
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: ColoredBox(color: AppColors.muted),
                    ),
                    // Positioned.fill + heightFactor 로 **꽉 찬 제약**을 준다.
                    // 그냥 Stack 자식으로 두면 자식 없는 DecoratedBox 가
                    // 느슨한 제약에서 0×0 으로 접혀 막대가 안 보인다
                    // (2026-09-20 노트 §12 와 같은 함정).
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: ratio,
                          heightFactor: 1,
                          child: const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF00A854), AppColors.primary],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 46,
            child: Text(split.paceLabel,
                textAlign: TextAlign.right,
                style: AppTextStyles.mono(
                    fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

/// '달린 구간' — 히어로와 별개로 경로를 한 번 더, 가로로 넓게 보여준다
/// (Figma 605-617). 히어로는 공유용 정사각 구도라 구간 모양이 눌려 보인다.
class _RouteSection extends StatelessWidget {
  const _RouteSection({required this.route});
  final List<LatLngPoint> route;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: const Color(0xFF080C14),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: route.length >= 2
            ? CustomPaint(
                painter: RoutePainter(
                  route: route,
                  background: const Color(0xFF080C14),
                ),
              )
            : Center(
                child: Text('경로가 기록되지 않았어요',
                    style: AppTextStyles.sans(
                        fontSize: 11, color: AppColors.mutedForeground)),
              ),
      ),
    );
  }
}

/// 경로 모드 히어로 — 다크맵 배경 + 그리드 + 네온 글로우 + 중앙 경로 + 하단 수치.
///
/// 사진을 등록하지 않았을 때의 기본 모습이다(`run-flow.md` 6 "사진 미등록").
class _RouteHeroBody extends StatelessWidget {
  const _RouteHeroBody({
    required this.route,
    required this.durStr,
    required this.distanceStr,
    required this.paceStr,
    required this.kcal,
    required this.dateLabel,
  });

  final List<LatLngPoint> route;
  final String durStr;
  final String distanceStr;
  final String paceStr;
  final int kcal;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final hasRoute = route.length >= 2;
    return Stack(
      fit: StackFit.expand,
      children: [
          // 배경: 어두운 지도 톤 그라데이션.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0A1220),
                  Color(0xFF060D18),
                  Color(0xFF040810),
                ],
                stops: [0, 0.5, 1],
              ),
            ),
          ),
          // 옅은 격자 — 지도처럼 보이게 하는 최소한의 장치.
          const CustomPaint(painter: _HeroGridPainter()),
          // 경로 뒤 네온 글로우.
          if (hasRoute)
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.1),
                  radius: 0.62,
                  colors: [Color(0x1200E87A), Color(0x0000E87A)],
                ),
              ),
            ),
          // 경로.
          if (hasRoute)
            Padding(
              padding: const EdgeInsets.fromLTRB(44, 64, 44, 130),
              child: CustomPaint(
                painter: RoutePainter(
                  route: route,
                  // 히어로 배경 위에 얹히므로 배경은 그리지 않는다.
                  background: Colors.transparent,
                ),
              ),
            )
          else
            Center(
              child: Text('경로가 기록되지 않았어요',
                  style: AppTextStyles.sans(
                      fontSize: 12, color: AppColors.mutedForeground)),
            ),
          // 하단 수치 — 아래에서 올라오는 어두운 그라데이션 위에 얹는다.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xF2040810), Color(0x00040810)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    text: TextSpan(
                      text: distanceStr,
                      style: AppTextStyles.display(fontSize: 44),
                      children: [
                        TextSpan(
                            text: ' km',
                            style: AppTextStyles.display(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withAlpha(0x8C))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _HeroStat(label: 'PACE', value: paceStr, unit: '/km'),
                      const _HeroDivider(),
                      _HeroStat(label: 'TIME', value: durStr),
                      const _HeroDivider(),
                      _HeroStat(
                          label: 'CAL',
                          value: kcal > 0 ? '$kcal' : '--',
                          unit: 'kcal'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // 워터마크 — 이 화면을 그대로 공유해도 출처가 남게.
                  Text('RUN EARTH · $dateLabel',
                      style: AppTextStyles.mono(
                          fontSize: 8, color: Colors.white.withAlpha(0x38))),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// 서버에 있는 사진(다른 기기에서 내려받은 기록). offline-handling.md §4-1.
///
/// 미리 받아두지 않으므로 오프라인이면 안 보인다 — 받는 중·실패 모두 로컬
/// 파일이 사라졌을 때와 같은 단색으로 둔다. 수치는 위에 그대로 얹힌다.
class _RemotePhoto extends ConsumerWidget {
  const _RemotePhoto({required this.objectPath});

  final String objectPath;

  static const _placeholder = ColoredBox(color: AppColors.muted);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = ref.watch(remoteCoverUrlProvider(objectPath)).valueOrNull;
    if (url == null) return _placeholder;
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _placeholder,
    );
  }
}

/// 사진 모드 히어로 — 등록한 사진을 배경으로 깔고 수치를 왼쪽에 세로로 쌓는다.
///
/// 정본은 Figma `App.tsx` 492-528(Strava 식). 경로 모드와 달리 **경로는 우하단
/// 작은 글리프로** 빠지고 사진이 주인공이 된다. 그대로 공유할 수 있는 한 장이
/// 목적이라 워터마크는 그대로 둔다.
class _PhotoHeroBody extends StatelessWidget {
  const _PhotoHeroBody({
    required this.photoPath,
    required this.durStr,
    required this.distanceStr,
    required this.paceStr,
    required this.route,
    required this.dateLabel,
  });

  final String photoPath;
  final String durStr;
  final String distanceStr;
  final String paceStr;
  final List<LatLngPoint> route;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final hasRoute = route.length >= 2;
    return Stack(
      fit: StackFit.expand,
      children: [
        // 사진 — 잘려도 꽉 채운다(4:5 비율에 맞춘다).
        // 다른 기기에서 내려받은 기록은 파일이 없어 서버에서 읽는다(§4-1).
        if (isRemoteCoverPath(photoPath))
          _RemotePhoto(objectPath: photoPath)
        else
          Image.file(
            File(photoPath),
            fit: BoxFit.cover,
            // 파일이 사라진 기록(기기 정리·백업 복원)도 화면이 깨지지 않게.
            errorBuilder: (_, _, _) => const ColoredBox(color: AppColors.muted),
          ),
        // 위아래 그라데이션 — 상단 버튼·뱃지와 하단 수치가 읽히게.
        //
        // 상단은 Figma(0.5)보다 진한 **0.65** 다. Figma 목업 사진은 어두운데,
        // 실제로는 하늘이 들어간 밝은 사진이 흔하다. 에뮬레이터에서 흰 하늘
        // 사진을 넣으니 0.5 로는 '일반' 뱃지(외곽선만 있는 칩)가 묻혔다.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xA6000000), Color(0x00000000), Color(0xC7000000)],
              stops: [0, 0.32, 1],
            ),
          ),
        ),
        // 왼쪽을 한 번 더 어둡게 — 수치가 전부 왼쪽에 있다.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0x8C000000), Color(0x00000000)],
              stops: [0, 0.65],
            ),
          ),
        ),
        // 경로 — 우하단에 작게, 사진 위에서 빛나게.
        if (hasRoute)
          Positioned(
            right: 14,
            bottom: 30,
            width: 104,
            height: 104,
            child: CustomPaint(
              painter: RoutePainter(route: route, background: Colors.transparent),
            ),
          ),
        // 수치 — 왼쪽에 세로로 쌓는다(Figma 505-515).
        Positioned(
          left: 16,
          bottom: 44,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const _PhotoStatLabel('DISTANCE'),
              RichText(
                text: TextSpan(
                  text: distanceStr,
                  style: AppTextStyles.display(fontSize: 48),
                  children: [
                    TextSpan(
                        text: ' km',
                        style: AppTextStyles.display(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withAlpha(0xA6))),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const _PhotoStatLabel('PACE'),
              RichText(
                text: TextSpan(
                  text: paceStr,
                  style: AppTextStyles.display(fontSize: 26),
                  children: [
                    TextSpan(
                        text: ' /km',
                        style: AppTextStyles.sans(
                            fontSize: 11,
                            color: Colors.white.withAlpha(0x8C))),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const _PhotoStatLabel('TIME'),
              Text(durStr, style: AppTextStyles.display(fontSize: 26)),
            ],
          ),
        ),
        // 워터마크 — 경로 모드와 같은 자리·같은 문구.
        Positioned(
          left: 16,
          bottom: 14,
          child: Text('RUN EARTH · $dateLabel',
              style: AppTextStyles.mono(
                  fontSize: 8, color: Colors.white.withAlpha(0x4D))),
        ),
      ],
    );
  }
}

/// 사진 모드 수치 위 작은 라벨(DISTANCE·PACE·TIME).
class _PhotoStatLabel extends StatelessWidget {
  const _PhotoStatLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(text,
          style: AppTextStyles.mono(
              fontSize: 8,
              letterSpacing: 1.6,
              color: Colors.white.withAlpha(0x80))),
    );
  }
}
