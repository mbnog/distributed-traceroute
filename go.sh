#!/bin/sh
set -e

#TODAY=$(date +%Y/%m/%d)
#case `uname` in
#   OpenBSD) TOMORROW=$(date -j +%Y/%m/%d $(( $(date +%Y%m%d%H%M) + 10000 ))) ;;
#   Linux) TOMORROW=$(date --date=tomorrow +%Y/%m/%d) ;;
#esac

[[ -f parse.awk ]] && rm parse.awk
curl -O -s https://lg.merlin.ca/ping/parse.awk

curl -s https://lg.merlin.ca/ping/targets \
| while read TGTNAME TGTIP ; do
    (
        # echo "TGTIP=[$TGTIP] TGTNAME=[$TGTNAME]"
        # mkdir -p ${TGTNAME}/$TODAY ${TGTNAME}/$TOMORROW   # preempt corner cases at 11:59

        echo -n "."
        # run in the background for 60 seconds; some overlap is OK!
        mtr \
            --interval 0.1 \
            --gracetime 1 \
            --timeout 1 \
            --report-wide \
            --report-cycles 600 \
            --show-ips \
            --aslookup \
            --no-dns \
            ${TGTIP} \
        | awk -f parse.awk -v TGT=${TGTNAME}  \
        | psql -q -b -h <DBHOST> -U <USERID> <DATABASE>    # fill these in
    ) &
done 

# start all over again
sleep 60
curl -s https://lg.merlin.ca/ping/go.sh | exec sh

# vim:set ai si sw=4 ts=4 nu et:
