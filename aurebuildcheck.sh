#!/bin/bash

export LANG=C

RED='\e[1;31m'
GREEN='\e[3;32m'
REDUL='\e[4;31m'
WHITEUL='\e[4;02m'
NC='\e[0m'
brokenpkgs=""

timestart() {
	TS=`date +%s.%N`
}

timeend() {
	TE=`date +%s.%N`
	TD=`calc -p $TE - $TS`
}



echo "Checking local packages..."

timestart
localpackages=`pacman -Qqm`
localpackagesamount=`echo $localpackages | wc -w`
echo -e "${localpackagesamount} packages will be checked...\n"

brokenpkgs=""
localpackages=`pacman -Qqm`
for package in $localpackages ; do
	echo "checking ${package}..."
	packagefiles=`pacman -Qql $package | grep -v "\.a\|\.png\|\.la\|\.ttf\|\.gz\|\.html\|\.css\|\.h\|\.xml\|\.rgb\|\.gif\|\.wav\|\.ogg\|\.mp3\|\.po\|\.txt\|\.jpg\|\.jpeg"`
	IFS=$'\n'
	for file in $packagefiles; do
		if (( $(file $file | grep -c 'ELF') != 0 )); then
			#  Is an ELF binary.
			if (( $(ldd $file 2>/dev/null | grep -c 'not found') != 0 )); then
				#  Missing lib.
				echo -e "\t ${RED}${file}${NC} ${REDUL}`ldd $file 2>/dev/null | grep 'not found'`${NC}" # >> $TEMPDIR/raw.txt
				brokenpkgs="${brokenpkgs} ${package}"
			fi
		fi
	done
done
echo "everything done."

echo -e "\n\nPackages which may need rebuild: \n ${RED}${brokenpkgs}${NC}\n"

timeend
TIME=`awk 'match($0,/[0-9]*.[0-9]{5}/) {print substr($0,RSTART,RLENGTH)}' <( echo "${TD}" )`

echo "Done after ${TIME} seconds."

echo "This script may not be able to distinguish between required and optional dependencies!"
