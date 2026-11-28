#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$ROOT/bin/omarchy-benchmark-functions"

# Exercise the shared calculator with a sub-millisecond sample and a minimum
# which is not the first sample.
measure_sample() {
  local -n duration="$1"
  duration=${samples[sample_index++]}
}
samples=(1750 2500 250)
sample_index=0
summary=$(benchmark_run_case "example" 3 measure_sample)
[[ $summary == "$(printf '%-34s avg %8s ms  min %8s ms  max %8s ms' example 1.500 0.250 2.500)" ]] ||
  fail "benchmark reports the mean, minimum and maximum" "$summary"
pass "benchmark reports the mean, minimum and maximum"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/home"
cp "$ROOT/bin/"{omarchy-dev-benchmark-cli,omarchy-dev-benchmark-theme-switcher,omarchy-benchmark-functions} "$tmp/bin/"
export HOME="$tmp/home" TMPDIR="$tmp" CALLS="$tmp/calls"

cat >"$tmp/bin/stub" <<'STUB'
#!/bin/bash
printf '%s %s\n' "${0##*/}" "$*" >>"$CALLS"
if [[ ${0##*/} == omarchy && ${FAIL_CLI:-} == 1 ]]; then
  exit 17
fi
if [[ ${0##*/} == omarchy-theme-switcher ]]; then
  mkdir -p "$XDG_CACHE_HOME/omarchy/theme-selector/previews"
  touch "$XDG_CACHE_HOME/omarchy/theme-selector/previews/mock.png"
fi
STUB
chmod +x "$tmp/bin/stub"
for stub in omarchy omarchy-theme-switcher omarchy-menu-images; do
  ln -s stub "$tmp/bin/$stub"
done

cli="$tmp/bin/omarchy-dev-benchmark-cli"
theme="$tmp/bin/omarchy-dev-benchmark-theme-switcher"
out=$("$cli" --repeat=2)
[[ $out == 'Omarchy CLI benchmark (2 runs each)'* && $(grep -c ' avg ' <<<"$out") == 9 ]] ||
  fail "CLI benchmark prints one summary per workload" "$out"
[[ $(wc -l <"$CALLS") == 18 ]] || fail "CLI benchmark repeats each of its nine workloads twice"
pass "CLI benchmark repeats each workload and reports its summary"

: >"$CALLS"
status=0
out=$(FAIL_CLI=1 "$cli" --repeat=2) || status=$?
[[ $status == 17 && $out == *'failed (exit 17)' && $(wc -l <"$CALLS") == 1 ]] ||
  fail "CLI benchmark stops on the first command failure" "$out"
pass "CLI benchmark preserves the failed case and its exit status"

: >"$CALLS"
out=$("$theme" --repeat=2)
[[ $out == 'Theme switcher benchmark (2 warm runs each)'* && $out == *'Theme previews: 1' && $(grep -c ' avg ' <<<"$out") == 3 ]] ||
  fail "theme benchmark reports the three warm workloads" "$out"
[[ $(grep -c ' cold' <<<"$out") == 3 && $(wc -l <"$CALLS") == 10 ]] ||
  fail "theme benchmark preserves cold runs, warm repetitions and preview setup" "$out"
[[ $(find "$tmp" -mindepth 1 -maxdepth 1 -type d | wc -l) == 2 ]] ||
  fail "theme benchmark removes its scratch directories by default"
pass "theme benchmark preserves workloads and cleans up caches by default"

out=$("$theme" --repeat=1 --keep-cache)
benchmark_cache=$(awk -F ': ' '/^Benchmark cache: / {print $2}' <<<"$out")
thumbnail_cache=$(awk -F ': ' '/^Thumbnail cache: / {print $2}' <<<"$out")
[[ -d $benchmark_cache && -d $thumbnail_cache && $benchmark_cache != "$thumbnail_cache" ]] ||
  fail "theme benchmark keeps and reports both caches on request" "$out"
[[ $(find "$tmp" -mindepth 1 -maxdepth 1 -type d | wc -l) == 4 ]] ||
  fail "theme benchmark does not keep its command stub directory"
pass "theme benchmark keeps only the two requested caches"

for command in "$cli" "$theme"; do
  status=0
  out=$("$command" --repeat=0 2>&1) || status=$?
  [[ $status == 2 && $out == '--repeat must be a positive integer' ]] ||
    fail "both benchmarks reject an invalid repeat count" "$out"
  out=$("$command" --help)
  [[ $out == Usage:* && $out == *'--repeat=<count>'* ]] ||
    fail "both benchmarks still show help" "$out"
done
pass "both benchmarks retain repeat validation and help"
