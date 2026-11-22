#!/bin/bash
# Обновляет сайт плана главы 1 и пушит его на GitHub.
# 1) На странице плана в claude.ai нажми «Скопировать для сайта».
# 2) Дважды кликни этот файл (или запусти в терминале).
#    Можно передать JSON файлом: ./update-site.command plan.json

cd "$(dirname "$0")" || exit 1

finish() {
  echo
  if [ -t 0 ]; then read -r -p "Нажми Enter, чтобы закрыть окно…" _; fi
  exit "$1"
}

TEMPLATE="site-template.html"
OUT="index.html"
TMP_JSON="$(mktemp "${TMPDIR:-/tmp}/bdplan.XXXXXX")"
trap 'rm -f "$TMP_JSON" "$TMP_JSON.out"' EXIT

if [ ! -f "$TEMPLATE" ]; then
  echo "✗ Не найден $TEMPLATE рядом со скриптом."
  finish 1
fi

# --- 1. Берём данные плана: из файла или из буфера обмена ---
if [ -n "$1" ]; then
  cp "$1" "$TMP_JSON" || finish 1
elif command -v pbpaste >/dev/null 2>&1; then
  pbpaste > "$TMP_JSON"
else
  echo "✗ Буфер обмена недоступен. Передай JSON файлом: ./update-site.command plan.json"
  finish 1
fi

if ! head -c 200 "$TMP_JSON" | grep -q '"exportedAt"' || ! grep -q '"tasks"' "$TMP_JSON"; then
  echo "✗ В буфере нет плана."
  echo "  Открой страницу плана в claude.ai, нажми «Скопировать для сайта» и запусти скрипт ещё раз."
  finish 1
fi

ISO_DATE="$(grep -o '"exportedAt":"[0-9-]*"' "$TMP_JSON" | head -1 | grep -o '[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}')"
if [ -n "$ISO_DATE" ]; then
  PLAN_DATE="$(echo "$ISO_DATE" | awk -F- '{print $3"."$2"."$1}')"
else
  PLAN_DATE="$(date +%d.%m.%Y)"
fi

# --- 2. Собираем index.html ---
perl -e '
  local $/;
  open my $t, "<:raw", $ARGV[0] or die "template: $!"; my $tpl = <$t>;
  open my $j, "<:raw", $ARGV[1] or die "json: $!";     my $js  = <$j>;
  $js =~ s/\s+\z//;
  $js =~ s{</}{<\\/}g;                       # не даём тексту закрыть <script>
  my $ph = "/*SNAPSHOT*/null";
  my $i = index($tpl, $ph); die "no snapshot placeholder\n" if $i < 0;
  substr($tpl, $i, length $ph) = $js;
  my $dp = "__PLAN_DATE__";
  while ((my $k = index($tpl, $dp)) >= 0) { substr($tpl, $k, length $dp) = $ARGV[2]; }
  open my $o, ">:raw", $ARGV[3] or die "out: $!"; print $o $tpl;
' "$TEMPLATE" "$TMP_JSON" "$PLAN_DATE" "$TMP_JSON.out" || { echo "✗ Не удалось собрать страницу."; finish 1; }

mv "$TMP_JSON.out" "$OUT"
TASKS="$(grep -o '"track":' "$OUT" | wc -l | tr -d ' ')"
echo "✓ index.html собран: план от $PLAN_DATE, блоков: $TASKS"

# --- 3. Коммит и пуш ---
if ! git --version >/dev/null 2>&1; then
  echo "• git в терминале не найден. Закоммить и запушь в GitHub Desktop: Commit to main → Push origin."
  finish 0
fi

if git diff --quiet -- "$OUT" && ! git ls-files --others --exclude-standard | grep -qx "$OUT"; then
  echo "• Изменений нет, сайт уже актуален."
  finish 0
fi

git add "$OUT"
git commit -q -m "План от $PLAN_DATE" && echo "✓ Коммит: План от $PLAN_DATE"

if git remote get-url origin >/dev/null 2>&1; then
  if git push -q origin HEAD; then
    echo "✓ Запушено. Сайт обновится через 1–2 минуты."
  else
    echo "✗ Push не прошёл. Запушь в GitHub Desktop: Push origin."
    finish 1
  fi
else
  echo "• У репозитория нет remote. Опубликуй его в GitHub Desktop (Publish repository)."
fi
finish 0
