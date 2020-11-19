#!/usr/bin/env bash

# author: balasr
# generate statistical measurments from simulation rums of epi firmware

set -e

usage () {
    echo "usage: $0 simdir outdir"
    exit
}


[[ -d $1 ]] || { echo "error: simdir does not exist"; usage; exit 1; }

simdir=$(realpath -s $1)
outdir=$(realpath -s $2)

pulptrace=../scripts/pulptrace
bin="$simdir/epi"
trace="$simdir/trace_core_1f_0.log"
interrupts="$simdir/fc_interrupts.log"
# outdir=stats/vanilla
# outdir=stats/opt1

echo "making sure $outdir exists"
mkdir -p $outdir

[[ -d $1 ]] || usage
[[ -d $2 ]] || usage

echo "info: pulptrace=$pulptrace"
echo "info: bin=$bin"
echo "info: trace=$trace"
echo "info: outdir=$outdir"

[[ -f $pulptrace ]] || { echo "error: pulptrace does not exist"; exit 1; }
[[ -f $bin ]] || { echo "error: bin does not exist"; exit 1; }
[[ -f $trace ]] || { echo "error: trace does not exist"; exit 1; }
[[ -d $outdir ]] || { echo "error: outdir does not exist"; exit 1; }
# generate ranges
if [[ ! -f "$outdir/occur.json" || ! -f "$outdir/interrupt_latency.csv" ]]; then
echo "$outdir/occur.json or $outdir/interrupt_latency.csv does not exists, generating range and interrupt data"
"$pulptrace" --analyze-interrupt "$interrupts" \
	   --interrupt 11 "<TIMER1_IRQ_handler>" \
	   --interrupt-out "$outdir/interrupt_latency.csv" \
	   --cycles --occur "<TIMER1_IRQ_handler>" \
	   --occur-json "$outdir/occur.json" \
    	   -o "$outdir/occur.log" "$trace" "$bin"
else
echo "warning: re-using $outdir/occur.json and $outdir/interrupt_latency.csv Stop if you don't want this"
fi

# "parse" ranges from occur.json
echo "parsing $outdir/occur.json, may be buggy"
readarray -t ranges < <(awk '/,/{gsub(/ /, "", $1); gsub(/,/, "", $1); print $1}' "$outdir/occur.json")

echo "using the following ranges: ${ranges[@]}"

lower=0
for i in "${ranges[@]}"; do
    if [[ $lower -eq 0 ]]; then
	lower=$i
	continue
    fi
    upper=$i
    echo "analyzing range from $lower to $i (diff" $(($upper - $lower))") cycles"
    "$pulptrace" --cycles --stats --range $lower $upper \
    	       --json "$outdir/stats-$lower-$upper.json" \
    	       -o "$outdir/trace-$lower-$upper.log" \
    	       "$trace" "$bin"

    # update lower range
    lower=$i
done

echo "summarizing results"
./summarize.py --json-avg "$outdir/avg" --json-worst "$outdir/worst" "$outdir"
