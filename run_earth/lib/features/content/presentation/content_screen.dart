import 'package:flutter/material.dart';

import '../../../core/models/marathon.dart';
import '../../../core/models/theme_run.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/images.dart';
import '../data/content_sample_data.dart';

enum _ContentTab { theme, marathon }

/// 콘텐츠 탭 — 테마 러닝 / 온라인 마라톤.
/// 정본: theme-running.md, online-marathon.md, 기능정의서 4-4.
class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  _ContentTab _tab = _ContentTab.theme;
  ThemeRun? _detail; // null 이면 목록, 값 있으면 상세 오버레이

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child:
                      Text('콘텐츠', style: AppTextStyles.display(fontSize: 24)),
                ),
                _SubTabBar(
                    tab: _tab, onChanged: (t) => setState(() => _tab = t)),
                Expanded(
                  child: _tab == _ContentTab.theme
                      ? _ThemeList(
                          onOpen: (tr) => setState(() => _detail = tr))
                      : const _MarathonList(),
                ),
              ],
            ),
            // ThemeRunDetail 슬라이드 인 오버레이.
            //
            // `Positioned.fill` 은 **여기**에 있어야 한다. 상세 위젯이 직접
            // 돌려주면 AnimatedSwitcher·SlideTransition 을 거치면서 Stack 의
            // 직계 자식이 아니게 되고, `Positioned.applyParentData` 예외가
            // 나면서 화면이 통째로 에러 위젯이 된다(2026-09-23 실기기 확인).
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, anim) => SlideTransition(
                  position: Tween(
                          begin: const Offset(1, 0), end: Offset.zero)
                      .animate(anim),
                  child: child,
                ),
                child: _detail == null
                    ? const SizedBox.shrink()
                    : _ThemeRunDetail(
                        key: ValueKey(_detail!.id),
                        run: _detail!,
                        onBack: () => setState(() => _detail = null),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 테마/마라톤 전환 — Figma 는 pill 두 개가 아니라 한 덩어리 세그먼트다.
/// 선택된 쪽이 카드색으로 떠오르고 나머지는 배경에 잠긴다.
class _SubTabBar extends StatelessWidget {
  const _SubTabBar({required this.tab, required this.onChanged});
  final _ContentTab tab;
  final ValueChanged<_ContentTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: AppColors.muted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: _segment('테마 러닝', tab == _ContentTab.theme,
                  () => onChanged(_ContentTab.theme)),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: _segment('온라인 마라톤', tab == _ContentTab.marathon,
                  () => onChanged(_ContentTab.marathon)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _segment(String label, bool sel, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        // 빈 곳을 눌러도 잡히게 — 세그먼트는 칸 전체가 버튼이다.
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: sel ? AppColors.card : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: sel ? Border.all(color: AppColors.border) : null,
          ),
          child: Center(
            child: Text(label,
                style: AppTextStyles.sans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: sel
                        ? AppColors.foreground
                        : AppColors.mutedForeground)),
          ),
        ),
      );
}

// ── 테마 러닝 ─────────────────────────────────────────────────

class _ThemeList extends StatelessWidget {
  const _ThemeList({required this.onOpen});
  final ValueChanged<ThemeRun> onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: sampleThemeRuns.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) =>
          _ThemeCard(run: sampleThemeRuns[i], onTap: () => onOpen(sampleThemeRuns[i])),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({required this.run, required this.onTap});
  final ThemeRun run;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사진 위에는 이모지와 이름만 얹는다. 설명·거리는 아래 줄로
            // 내려가서, 사진이 글자에 가려지지 않는다(Figma).
            SizedBox(
              height: 96,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ColoredBox(color: AppColors.muted),
                  ),
                  if (run.img.isNotEmpty)
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.6,
                        child: Image.network(
                          unsplashUrl(run.img, w: 500, h: 192),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  // 왼쪽만 어둡게 — 글자가 놓이는 쪽이다.
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.black.withAlpha(0xB3),
                            Colors.black.withAlpha(0x4D),
                            Colors.transparent,
                          ],
                          stops: const [0, 0.5, 1],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 12,
                    child: Row(
                      children: [
                        Text(run.emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 6),
                        Text(run.name,
                            style: AppTextStyles.sans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(run.desc,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.sans(
                            fontSize: 10,
                            color: AppColors.mutedForeground)),
                  ),
                  const SizedBox(width: 8),
                  Text('${run.km}km',
                      style: AppTextStyles.mono(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right,
                      size: 14, color: AppColors.mutedForeground),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeRunDetail extends StatelessWidget {
  const _ThemeRunDetail(
      {super.key, required this.run, required this.onBack});
  final ThemeRun run;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    // 화면을 덮는 일(`Positioned.fill`)은 부모가 한다 — 위 주석 참조.
    return ColoredBox(
        color: AppColors.background,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // 히어로
            SizedBox(
              height: 220,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [Color(0xFF1A2336), Color(0xFF090C14)],
                      ),
                    ),
                  ),
                  if (run.img.isNotEmpty)
                    Image.network(
                      unsplashUrl(run.img, w: 600, h: 440),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  // 하단 스크림(제목 가독성).
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xCC000000)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: IconButton(
                      onPressed: onBack,
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withAlpha(0x80),
                          border:
                              Border.all(color: Colors.white.withAlpha(0x26)),
                        ),
                        child: const Icon(Icons.arrow_back,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 12,
                    child: Text(run.name,
                        style: AppTextStyles.display(fontSize: 30)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 태그 행
                  Wrap(spacing: 8, children: [
                    _tag('테마 러닝'),
                    _tag('${run.km}km'),
                  ]),
                  const SizedBox(height: 16),
                  Text('코스 소개',
                      style: AppTextStyles.sans(
                          fontSize: 12, color: AppColors.mutedForeground)),
                  const SizedBox(height: 6),
                  Text(run.desc,
                      style: AppTextStyles.sans(fontSize: 14, color: AppColors.foreground)),
                  const SizedBox(height: 20),
                  // 경로 미리보기 (좌표 데이터 필요)
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFF080C14),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                        child: Text('🗺  경로 미리보기 (코스 좌표 필요)',
                            style: AppTextStyles.sans(
                                fontSize: 12,
                                color: AppColors.mutedForeground))),
                  ),
                  const SizedBox(height: 20),
                  // 하단 버튼
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onBack,
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('뒤로가기',
                              style: AppTextStyles.display(
                                  fontSize: 15,
                                  color: AppColors.foreground)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                                colors: [Color(0xFF00E87A), Color(0xFF00C060)]),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {}, // 이후: 달리기 탭(테마 러닝) 이동
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                child: Center(
                                  child: Text('달리러 가기',
                                      style: AppTextStyles.display(
                                          fontSize: 15,
                                          color: Colors.black)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }

  Widget _tag(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.muted,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(label,
            style: AppTextStyles.sans(
                fontSize: 11, color: AppColors.foreground)),
      );
}

// ── 온라인 마라톤 ─────────────────────────────────────────────

class _MarathonList extends StatelessWidget {
  const _MarathonList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: sampleMarathons.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _MarathonCard(sampleMarathons[i]),
    );
  }
}

class _MarathonCard extends StatelessWidget {
  const _MarathonCard(this.m);
  final Marathon m;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 히어로 ──────────────────────────────────────────
          SizedBox(
            height: 96,
            child: Stack(
              children: [
                const Positioned.fill(
                  child: ColoredBox(color: AppColors.muted),
                ),
                if (m.img.isNotEmpty)
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.7,
                      child: Image.network(
                        unsplashUrl(m.img, w: 600, h: 200),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                // 왼쪽이 가장 어둡다 — 글자가 다 왼쪽에 있다.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppColors.background.withAlpha(0xEB),
                          AppColors.background.withAlpha(0x99),
                          AppColors.background.withAlpha(0x26),
                        ],
                        stops: const [0, 0.55, 1],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.place_outlined,
                              size: 10, color: Colors.white.withAlpha(0x99)),
                          const SizedBox(width: 4),
                          Text(m.location,
                              style: AppTextStyles.mono(
                                  fontSize: 9,
                                  color: Colors.white.withAlpha(0x99))),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.name,
                                    style: AppTextStyles.display(fontSize: 18)),
                                const SizedBox(height: 2),
                                Text('목표 ${m.distance} · ${m.course}',
                                    style: AppTextStyles.sans(
                                        fontSize: 9,
                                        color: Colors.white.withAlpha(0x99))),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _DdayBadge(dday: m.dday, ended: m.ended),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ── 통계행 — 참여자 수와 내 순위 ────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_outline,
                    size: 11, color: AppColors.mutedForeground),
                const SizedBox(width: 4),
                Text('${m.participants}명 참여 중',
                    style: AppTextStyles.mono(
                        fontSize: 9, color: AppColors.mutedForeground)),
                const Spacer(),
                if (m.myRank != null && m.myTime != null) ...[
                  Icon(Icons.emoji_events_outlined,
                      size: 11,
                      color:
                          m.ended ? AppColors.typeOnline : AppColors.primary),
                  const SizedBox(width: 4),
                  Text('${m.myRank} ${m.myTime}',
                      style: AppTextStyles.mono(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: m.ended
                              ? AppColors.typeOnline
                              : AppColors.primary)),
                ],
              ],
            ),
          ),
          // ── 상품 + 참여 버튼 ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Text(m.prizeEmoji, style: const TextStyle(fontSize: 11)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(m.prize,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.sans(
                          fontSize: 9, color: AppColors.mutedForeground)),
                ),
                if (!m.ended) ...[
                  const SizedBox(width: 8),
                  _MarathonCta(m),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    // 끝난 대회는 카드째 물러나 있는다 — 목록에서 지우지는 않는다.
    return m.ended ? Opacity(opacity: 0.6, child: card) : card;
  }
}

class _DdayBadge extends StatelessWidget {
  const _DdayBadge({required this.dday, required this.ended});
  final String dday;
  final bool ended;

  @override
  Widget build(BuildContext context) {
    final color = ended ? AppColors.mutedForeground : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.badgeBackground(color),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(0x40)),
      ),
      child: Text(ended ? '종료' : dday,
          style: AppTextStyles.mono(
              fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _MarathonCta extends StatelessWidget {
  const _MarathonCta(this.m);
  final Marathon m;

  /// 참여 전은 옅은 네온 테두리, 참여 중은 꽉 찬 네온 — 이미 들어간 대회가
  /// 한눈에 도드라진다(Figma). 종료된 대회에는 아예 붙지 않는다.
  @override
  Widget build(BuildContext context) {
    final joined = m.joined;
    return Material(
      color: joined
          ? AppColors.primary
          : AppColors.primary.withAlpha(0x1F),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: joined
                ? null
                : Border.all(color: AppColors.primary.withAlpha(0x35)),
          ),
          child: Text(joined ? '참여 중 ✓' : '참여하기',
              style: AppTextStyles.sans(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: joined ? Colors.black : AppColors.primary)),
        ),
      ),
    );
  }
}
