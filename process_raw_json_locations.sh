#!/usr/bin/env bash

infile_regex=''
outfile=''
parallel='false'

print_usage() {
  printf "Usage: ./process.sh [-p] -i 'infile.*regex.json' -o outfile.csv"
}

while getopts ':i:o:p' flag; do
  case "${flag}" in
    i) infiles="${OPTARG}" ;;
    o) outfile="${OPTARG}" ;;
    p) parallel='true' ;;
    # TODO: verbose: use pv for run_single, --eta for run_parallel
    *) print_usage
       exit 1 ;;
  esac
done

run_single() {
  ls $infiles |
    xargs -o jq -r '.data.list[] | [.lastUpdateTime, .location.lat, .location.lon, .tripId, .vehicleId] | @csv' |
    cat |
    sort -u > $outfile
}

run_parallel() {
  ls $infiles |
    parallel 'jq -r ".data.list[] | [.lastUpdateTime, .location.lat, .location.lon, .tripId, .vehicleId] | @csv" {} | cat' |
    sort -u > $outfile
}

if [ $parallel == 'true' ]
then
  run_parallel
else
  run_single
fi
