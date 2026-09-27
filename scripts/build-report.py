# -*- coding: utf-8 -*-
"""팀 공유 리포트 md -> 자체포함 HTML.

스크린샷을 폭 540px 로 줄여 base64 로 박는다. 파일 하나만 보내면 끝나게 하려는
것이다 (스크린샷은 `.gitignore` 로 빠져 있어 경로 참조로는 받는 사람 쪽에서 깨진다).

    python scripts/build-report.py <입력.md> <출력.html>
    python scripts/build-report.py docs/dev-notes/2026-09-27-team-report.md \
                                   docs/dev-notes/2026-09-27-team-report.html

md 문법은 전부가 아니라 리포트에 쓰는 것만 다룬다 — 제목 · 문단 · 목록 · 표 ·
인용 · 굵게/코드/취소선, 그리고 스크린샷 묶음:

    :::figs
    ![캡션](../assets/screenshots/2026-09-27/01-login.jpg)
    ![캡션](../assets/screenshots/2026-09-27/02-login-account-picker.jpg)
    :::

묶음 안 장수에 따라 배치가 바뀐다 (2·4장은 2열, 3장은 3열, 1장은 단독 축소).
필요한 것: Pillow.
"""
import base64
import html as _html
import io
import re
import sys
from pathlib import Path

from PIL import Image

SRC = Path(sys.argv[1])
OUT = Path(sys.argv[2])
IMG_WIDTH = 540
JPEG_QUALITY = 80

_cache = {}


def data_uri(rel_path: str) -> str:
    """md 의 상대경로를 읽어 축소한 뒤 data URI 로."""
    if rel_path in _cache:
        return _cache[rel_path]
    p = (SRC.parent / rel_path).resolve()
    if not p.exists():
        raise SystemExit(f"이미지 없음: {p}")
    im = Image.open(p)
    if im.mode != "RGB":
        im = im.convert("RGB")
    if im.width > IMG_WIDTH:
        h = round(im.height * IMG_WIDTH / im.width)
        im = im.resize((IMG_WIDTH, h), Image.LANCZOS)
    buf = io.BytesIO()
    im.save(buf, "JPEG", quality=JPEG_QUALITY, optimize=True, progressive=True)
    uri = "data:image/jpeg;base64," + base64.b64encode(buf.getvalue()).decode()
    _cache[rel_path] = uri
    return uri


IMG_RE = re.compile(r"^!\[(?P<alt>[^\]]*)\]\((?P<src>[^)]+)\)\s*$")


def inline(text: str) -> str:
    """굵게 · 코드 · 취소선 · 기울임. 이스케이프를 먼저 한다."""
    t = _html.escape(text, quote=False)
    t = re.sub(r"`([^`]+)`", r"<code>\1</code>", t)
    t = re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", t)
    t = re.sub(r"~~([^~]+)~~", r"<del>\1</del>", t)
    t = re.sub(r"(?<![\w*])\*([^*\n]+)\*(?![\w*])", r"<em>\1</em>", t)
    return t


def figure(alt: str, src: str) -> str:
    return (
        '<figure class="shot">'
        f'<img loading="lazy" alt="{_html.escape(alt, quote=True)}" src="{data_uri(src)}">'
        f'<figcaption>{inline(alt)}</figcaption>'
        "</figure>"
    )


def render(lines):
    out = []
    i = 0
    n = len(lines)

    def flush_para(buf):
        if buf:
            out.append("<p>" + inline(" ".join(buf)) + "</p>")
            buf.clear()

    para = []
    while i < n:
        line = lines[i].rstrip("\n")
        stripped = line.strip()

        # 스크린샷 묶음
        if stripped == ":::figs":
            flush_para(para)
            figs = []
            i += 1
            while i < n and lines[i].strip() != ":::":
                m = IMG_RE.match(lines[i].strip())
                if m:
                    figs.append(figure(m.group("alt"), m.group("src")))
                i += 1
            i += 1
            cls = "figs" + {2: " figs-2", 3: " figs-3", 4: " figs-4"}.get(len(figs), "")
            out.append(f'<div class="{cls}">' + "".join(figs) + "</div>")
            continue

        # 단독 이미지
        m = IMG_RE.match(stripped)
        if m:
            flush_para(para)
            out.append('<div class="figs figs-1">' + figure(m.group("alt"), m.group("src")) + "</div>")
            i += 1
            continue

        # 구분선
        if stripped == "---":
            flush_para(para)
            out.append("<hr>")
            i += 1
            continue

        # 제목
        hm = re.match(r"^(#{1,4})\s+(.*)$", stripped)
        if hm:
            flush_para(para)
            lvl = len(hm.group(1))
            out.append(f"<h{lvl}>{inline(hm.group(2))}</h{lvl}>")
            i += 1
            continue

        # 표
        if stripped.startswith("|") and i + 1 < n and re.match(r"^\|[\s:|-]+\|$", lines[i + 1].strip()):
            flush_para(para)
            header = [c.strip() for c in stripped.strip("|").split("|")]
            i += 2
            rows = []
            while i < n and lines[i].strip().startswith("|"):
                rows.append([c.strip() for c in lines[i].strip().strip("|").split("|")])
                i += 1
            th = "".join(f"<th>{inline(c)}</th>" for c in header)
            tb = "".join(
                "<tr>" + "".join(f"<td>{inline(c)}</td>" for c in r) + "</tr>" for r in rows
            )
            out.append(f'<div class="tw"><table><thead><tr>{th}</tr></thead><tbody>{tb}</tbody></table></div>')
            continue

        # 인용
        if stripped.startswith(">"):
            flush_para(para)
            buf = []
            while i < n and lines[i].strip().startswith(">"):
                buf.append(lines[i].strip().lstrip(">").strip())
                i += 1
            out.append("<blockquote><p>" + inline(" ".join(buf)) + "</p></blockquote>")
            continue

        # 목록 (한 단계 들여쓰기까지 이어붙인다)
        if re.match(r"^[-*]\s+", stripped):
            flush_para(para)
            items = []
            while i < n:
                s = lines[i].rstrip("\n")
                if re.match(r"^[-*]\s+", s.strip()) and not s.startswith("  "):
                    items.append(re.sub(r"^[-*]\s+", "", s.strip()))
                elif s.startswith("  ") and s.strip() and items:
                    items[-1] += " " + s.strip()
                else:
                    break
                i += 1
            out.append("<ul>" + "".join(f"<li>{inline(it)}</li>" for it in items) + "</ul>")
            continue

        # 빈 줄 / 본문
        if not stripped:
            flush_para(para)
        else:
            para.append(stripped)
        i += 1

    flush_para(para)
    return "\n".join(out)


CSS = """
:root{
  --ground:#070911; --surface:#0D1018; --surface-2:#151923;
  --fg:#EDF0F7; --fg-dim:#9AA3B5; --fg-faint:#6B7280;
  --primary:#00E87A; --accent:#FF5F1F; --warn:#FACC15; --danger:#FF2D55;
  --hair:rgba(255,255,255,.08); --hair-2:rgba(255,255,255,.16);
  --display:"Barlow Condensed","Noto Sans KR",system-ui,sans-serif;
  --body:"DM Sans","Noto Sans KR",system-ui,sans-serif;
  --mono:"DM Mono",ui-monospace,monospace;
}
*{box-sizing:border-box}
html{-webkit-text-size-adjust:100%}
body{margin:0;background:var(--ground);color:var(--fg);font-family:var(--body);
  font-size:15px;line-height:1.75;-webkit-font-smoothing:antialiased}
.topbar{position:sticky;top:0;z-index:10;background:rgba(7,9,17,.93);
  backdrop-filter:blur(10px);border-bottom:1px solid var(--hair)}
.topbar-inner{max-width:880px;margin:0 auto;padding:12px 20px;display:flex;
  align-items:baseline;gap:12px;flex-wrap:wrap}
.mark{font-family:var(--display);font-weight:700;font-size:20px;letter-spacing:.02em;
  color:var(--primary);text-transform:uppercase}
.mark-sub{font-size:12px;color:var(--fg-faint);font-family:var(--mono)}
.wrap{max-width:880px;margin:0 auto;padding:0 20px 80px}
h1{font-family:var(--display);font-size:clamp(30px,6vw,42px);font-weight:700;
  line-height:1.15;margin:36px 0 14px;letter-spacing:.01em}
h2{font-family:var(--display);font-size:clamp(23px,4.4vw,29px);font-weight:600;
  margin:52px 0 14px;padding-top:6px;letter-spacing:.01em}
h3{font-size:17px;font-weight:700;margin:34px 0 10px;color:var(--fg)}
h4{font-size:14px;font-weight:700;margin:26px 0 8px;color:var(--fg-dim);
  text-transform:none;letter-spacing:.02em}
p{margin:0 0 14px}
ul{margin:0 0 16px;padding-left:20px}
li{margin:0 0 7px}
strong{color:#fff;font-weight:700}
del{color:var(--fg-faint)}
code{font-family:var(--mono);font-size:.88em;background:var(--surface-2);
  border:1px solid var(--hair);border-radius:5px;padding:1px 5px;color:var(--fg-dim)}
hr{border:0;border-top:1px solid var(--hair);margin:40px 0}
blockquote{margin:18px 0;padding:14px 18px;background:var(--surface);
  border-left:3px solid var(--primary);border-radius:0 10px 10px 0}
blockquote p{margin:0;color:var(--fg-dim)}
.tw{overflow-x:auto;margin:0 0 20px;border:1px solid var(--hair);border-radius:12px}
table{border-collapse:collapse;width:100%;font-size:13.5px;min-width:440px}
th{background:var(--surface-2);text-align:left;font-weight:700;color:var(--fg);
  padding:11px 14px;border-bottom:1px solid var(--hair-2);white-space:nowrap}
td{padding:11px 14px;border-bottom:1px solid var(--hair);color:var(--fg-dim);
  vertical-align:top}
tr:last-child td{border-bottom:0}
td strong{color:var(--fg)}
.figs{display:grid;gap:14px;margin:20px 0 24px;
  grid-template-columns:repeat(auto-fit,minmax(150px,1fr))}
.figs-1{grid-template-columns:minmax(0,290px);justify-content:start}
.figs-2{grid-template-columns:repeat(2,minmax(0,1fr));max-width:620px}
.figs-3{grid-template-columns:repeat(3,minmax(0,1fr))}
/* 4장은 한 줄에 몰면 글씨가 안 읽혀서 2x2 로 내린다 */
.figs-4{grid-template-columns:repeat(2,minmax(0,1fr));max-width:620px}
.shot{margin:0;display:flex;flex-direction:column;gap:8px}
.shot img{width:100%;height:auto;display:block;border-radius:12px;
  border:1px solid var(--hair-2);background:var(--surface)}
.shot figcaption{font-size:12px;line-height:1.5;color:var(--fg-faint);
  font-family:var(--mono)}
.foot{margin-top:56px;padding-top:20px;border-top:1px solid var(--hair);
  font-size:12px;color:var(--fg-faint);font-family:var(--mono)}
@media (max-width:560px){
  .figs-3{grid-template-columns:repeat(2,minmax(0,1fr))}
  body{font-size:14.5px}
  .figs-2,.figs{grid-template-columns:minmax(0,1fr)}
  .figs-1{grid-template-columns:minmax(0,1fr)}
}
"""

md = SRC.read_text(encoding="utf-8").splitlines()
body = render(md)

doc = f"""<!doctype html>
<html lang="ko">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Run Earth 개발 현황 (2026-09-27)</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@600;700&family=DM+Mono:wght@400;500&family=DM+Sans:wght@400;500;700&family=Noto+Sans+KR:wght@400;500;700&display=swap">
<style>{CSS}</style>
<div class="topbar"><div class="topbar-inner">
  <span class="mark">Run Earth</span>
  <span class="mark-sub">개발 현황 · 2026-09-27</span>
</div></div>
<div class="wrap">
{body}
<div class="foot">이 파일은 스크린샷을 내장하고 있어 단독으로 열립니다 · 폭 {IMG_WIDTH}px 로 축소</div>
</div>
</html>
"""

OUT.write_text(doc, encoding="utf-8")
kb = OUT.stat().st_size / 1024
print(f"생성: {OUT}")
print(f"크기: {kb:,.0f} KB ({kb/1024:.1f} MB)")
print(f"내장 이미지: {len(_cache)}장")
