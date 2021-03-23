#!/bin/sh

usage () {
 echo "Usage: $(basename "$0") 1fm|2fm|1r|2r|3r|dmb|scr|rki(KBS라디오)"
 echo "   or: $(basename "$0") mbcm(MBC Channel M)|mbc4u(MBC FM4U)|mbcfm(MBC FM)"
 echo "   or: $(basename "$0") sbsp(SBS파워FM)|sbsl(SBS러브FM)"
 echo "   or: $(basename "$0") cbs(CBS음악FM)|tbs(tbsFM)|tbse(tbseFM)|gugak(국악방송)"
 echo "   or: $(basename "$0") stop(정지)"
 echo "Play Korean radio with MPD"
}

pls () {
 url=$(echo "$1" | grep -o '.*/')$(curl -s "$1" | tail -1)
}

kbsr () {
#if [ "$1" = 24 ]; then
# pls $(curl -s http://serpent0.duckdns.org:8088/kbsfm.pls | head -2 | tail -1 | cut -d\= -f2-)
#else
  url=$(curl -s "http://onair.kbs.co.kr/index.html?sname=onair&stype=live&ch_code=$1" | grep service_url | tail -1 | cut -d\" -f16 | cut -d\\ -f1)
#fi
}

mbcr () {
 pls $(curl -s "http://miniplay.imbc.com/AACLiveURL.ashx?channel=$1&agent=android&protocol=M3U8")
}

sbsr () {
#api=$(curl -s "http://apis.sbs.co.kr/play-api/1.0/onair/channel/S$1?v_type=2&platform=pcweb&protocol=hls" | grep -o 'mediaurl.*' | cut -d\" -f3)
#url=$(curl -s "$api" | tail -1)
 api=$(curl -s "http://api.sbs.co.kr/vod/_v1/Onair_Media_Auth_Security.jsp?channelPath=$1&streamName=$2.stream&playerType=mobile")
 url=$(curl -s $(sbs_dec.py "$api") | tail -1)
}

case $1 in
 1fm)   kbsr 24  ;;
 2fm)   kbsr 25  ;;
 1r)    kbsr 21  ;;
 2r)    kbsr 22  ;;
 3r)    kbsr 23  ;;
 scr)   kbsr I26 ;;
 rki)   kbsr I92 ;;
 mbcm)  mbcr chm ;;
 mbc4u) mbcr mfm ;;
 mbcfm) mbcr sfm ;;
 sbsp)  #sbsr 07
	sbsr powerpc powerfm ;;
 sbsl)  #sbsr 08
	sbsr lovepc  lovefm  ;;
 cbs)   pls "http://aac.cbs.co.kr/cbs939/cbs939.stream/playlist.m3u8" ;;
 tbs)   pls "http://tbs.hscdn.com/tbsradio/fm/playlist.m3u8" ;;
 tbse)  pls "http://tbs.hscdn.com/tbsradio/efm/playlist.m3u8" ;;
 gugak) pls "http://mgugaklive.nowcdn.co.kr/gugakradio/gugakradio.stream/playlist.m3u8" ;;
 stop)  mpc stop ; mpc del $(mpc playlist | wc -l) ; exit ;;
 *)     usage ; exit ;;
esac

[ -z "$url" ] && echo "$1 stream is not available!" && exit
mpc add $url && mpc play $(mpc playlist | wc -l)