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
            // ThemeRunDetail 슬라이드 인 오버레이
            AnimatedSwitcher(
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
          ],
        ),
      ),
    );
  }
}

class _SubTabBar extends StatelessWidget {
  const _SubTabBar({required this.tab, required this.onChanged});
  final _ContentTab tab;
  final ValueChanged<_ContentTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          _pill('테마 러닝', tab == _ContentTab.theme,
              () => onChanged(_ContentTab.theme)),
          const SizedBox(width: 8),
          _pill('온라인 마라톤', tab == _ContentTab.marathon,
              () => onChanged(_ContentTab.marathon)),
        ],
      ),
    );
  }

  Widget _pill(String label, bool sel, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: sel
                ? AppColors.badgeBackground(AppColors.primary)
                : AppColors.muted,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
                color: sel ? AppColors.primary : AppColors.border),
          ),
          child: Text(label,
              style: AppTextStyles.sans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: sel ? AppColors.primary : AppColors.mutedForeground)),
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
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF141A2A), Color(0xFF0C1018)],
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (run.img.isNotEmpty)
              Positioned.fill(
                child: Image.network(
                  unsplashUrl(run.img, w: 600, h: 240),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            // 텍스트 가독성용 어두운 스크림.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withAlpha(0xD9),
                      Colors.black.withAlpha(0x40),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -8,
              top: -10,
              child: Text(run.emoji,
                  style: TextStyle(
                      fontSize: 90,
                      color: Colors.white.withAlpha(0x14))),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(run.emoji, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Text(run.name,
                          style: AppTextStyles.display(fontSize: 20)),
                    ],
                  ),
                  Text(run.desc,
                      style: AppTextStyles.sans(
                          fontSize: 12, color: AppColors.mutedForeground)),
                  RichText(
                    text: TextSpan(
                      text: '${run.km}',
                      style: AppTextStyles.display(
                          fontSize: 18, color: AppColors.primary),
                      children: [
                        TextSpan(
                            text: ' km',
                            style: AppTextStyles.sans(
                                fontSize: 10,
                                color: AppColors.mutedForeground)),
                      ],
                    ),
                  ),
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
    return Positioned.fill(
      child: ColoredBox(
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 히어로
          SizedBox(
            height: 96,
            child: Stack(
              children: [
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF16233A), Color(0xFF0C1018)],
                      ),
                    ),
                  ),
                ),
                if (m.img.isNotEmpty)
                  Positioned.fill(
                    child: Image.network(
                      unsplashUrl(m.img, w: 600, h: 200),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withAlpha(0xD9),
                          Colors.black.withAlpha(0x40),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📍 ${m.location}',
                        style: AppTextStyles.sans(
                            fontSize: 10, color: AppColors.mutedForeground)),
                    const SizedBox(height: 4),
                    Text(m.name, style: AppTextStyles.display(fontSize: 18)),
                    const SizedBox(height: 2),
                    Text('${m.distance} · ${m.course}',
                        style: AppTextStyles.sans(
                            fontSize: 11, color: AppColors.mutedForeground)),
                  ],
                ),
                _DdayBadge(dday: m.dday, ended: m.ended),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('👤 ${m.participants}명 참여 중',
                        style: AppTextStyles.sans(
                            fontSize: 11, color: AppColors.mutedForeground)),
                    const Spacer(),
                    Text('${m.prizeEmoji} ${m.prize}',
                        style: AppTextStyles.sans(
                            fontSize: 11, color: AppColors.foreground)),
                  ],
                ),
                if (m.joined && m.myRank != null) ...[
                  const SizedBox(height: 8),
                  Text('🏆 ${m.myRank} · ${m.myTime}',
                      style: AppTextStyles.sans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.typeOnline)),
                ],
                const SizedBox(height: 12),
                _MarathonCta(m),
              ],
            ),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    if (m.ended) {
      return _button('종료됨', AppColors.muted, AppColors.mutedForeground, null);
    }
    if (m.joined) {
      return _button('참여 중', AppColors.muted, AppColors.mutedForeground, null);
    }
    return _button('참가하기', AppColors.primary, Colors.black, () {});
  }

  Widget _button(String label, Color bg, Color fg, VoidCallback? onTap) =>
      SizedBox(
        width: double.infinity,
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(label,
                    style: AppTextStyles.display(fontSize: 15, color: fg)),
              ),
            ),
          ),
        ),
      );
}
