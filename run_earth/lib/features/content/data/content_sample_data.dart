import '../../../core/models/marathon.dart';
import '../../../core/models/theme_run.dart';

/// 임시 샘플 콘텐츠 (Figma App.tsx 의 THEME_RUNS / MARATHONS 와 동일).
/// 실제 코스 좌표·이미지는 콘텐츠팀 작업 대상. 이후 서버/DB 데이터로 대체.

const sampleThemeRuns = <ThemeRun>[
  ThemeRun(
      id: 'theme-1',
      emoji: '🐟',
      name: '붕어빵런',
      desc: '겨울 간식 명소를 잇는 테마 코스',
      km: 5.2,
      img: ''),
  ThemeRun(
      id: 'theme-2',
      emoji: '🌊',
      name: '한강야경런',
      desc: '한강변 야경을 감상하며 달리기',
      km: 8.7,
      img: ''),
  ThemeRun(
      id: 'theme-3',
      emoji: '🗼',
      name: 'N서울타워런',
      desc: '남산을 오르는 도전 코스',
      km: 4.5,
      img: ''),
];

const sampleMarathons = <Marathon>[
  Marathon(
    id: 'm-1',
    courseId: 'c-banpo',
    name: '7월 온라인 하프마라톤',
    distance: '21.1km',
    course: '평지 코스',
    location: '서울 · 반포한강공원',
    dday: 'D-12',
    prize: '금메달 + 5,000P',
    prizeEmoji: '🥇',
    joined: true,
    ended: false,
    participants: '1,204',
    myRank: '현재 1위',
    myTime: '1:31:22',
    img: '',
  ),
  Marathon(
    id: 'm-2',
    courseId: 'c-gwanghwamun',
    name: '6월 온라인 10K 마라톤',
    distance: '10km',
    course: '도심 코스',
    location: '서울 · 광화문 광장',
    dday: 'D-28',
    prize: '은메달 + 2,000P',
    prizeEmoji: '🥈',
    joined: false,
    ended: false,
    participants: '892',
    myRank: null,
    myTime: null,
    img: '',
  ),
];
