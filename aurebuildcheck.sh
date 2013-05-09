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
	BROKEN="false"
	echo "checking ${package}..."
	packagefiles=`pacman -Qql $package | grep -v "\/$\|\.a\|\.png\|\.la\|\.ttf\|\.gz\|\.html\|\.css\|\.h\|\.xml\|\.rgb\|\.gif\|\.wav\|\.ogg\|\.mp3\|\.po\|\.txt\|\.jpg\|\.jpeg\|\.bmp\|\.xcf"`
	IFS=$'\n'
	for file in $packagefiles; do
		if (( $(file $file | grep -c 'ELF') != 0 )); then
			#  Is an ELF binary.
			libs=`readelf -d "${file}" | awk '/NEEDED.*\[.*\]/''{print $5}' | awk  '{ gsub(/\[|\]/, "") ; print  }'`
			for lib in ${libs} ; do
			# needed libs
				if [ -z `whereis ${lib} | awk '{print $2}'` ] ; then
					#  Missing lib.
					echo -e "\t ${RED}${file}${NC} needs ${REDUL}$lib${NC}" # >> $TEMPDIR/raw.txt
					BROKEN="true" # to avoid packages being listed in the brokenpkg array several times
				fi
			done
		fi
	done

	if [[ ${BROKEN} == "true" ]] ; then
		brokenpkgs="${brokenpkgs} ${package}"
	fi

done
echo "everything done."

echo -e "\n\nPackages which may need rebuild: \n ${RED}${brokenpkgs}${NC}\n"

timeend
TIME=`awk 'match($0,/[0-9]*.[0-9]{5}/) {print substr($0,RSTART,RLENGTH)}' <( echo "${TD}" )`

echo "Done after ${TIME} seconds."

echo "This script may not be able to distinguish between required and optional dependencies!"
