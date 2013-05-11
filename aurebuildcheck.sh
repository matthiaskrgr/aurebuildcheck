#!/bin/bash

export LANG=C

RED='\e[1;31m'
GREEN='\e[1;32m'
REDUL='\e[4;31m'
WHITEUL='\e[4;02m'
NC='\e[0m'
brokenpkgs=""

timestart() {
	TS=`date +%s`
}

timeend() {
	TE=`date +%s`
    let TD="$TE-$TS"
}




timestart
localpackages=`pacman -Qqm`
localpackagesamount=`echo ${localpackages} | wc -w`
# ${localpackages} > 0 since aurebuildcheck in aur
if  [[ ${localpackagesamount} = 1 ]] ; then
	echo -e "Checking ${localpackagesamount} local package...\n"
else
	echo -e "Checking ${localpackagesamount} local packages...\n"
fi

brokenpkgs=""
for package in $localpackages ; do
	BROKEN="false"
	printf "checking ${package}..."
	packagefiles=`pacman -Qql $package | grep -v "\/$\|\.a\|\.png\|\.la\|\.ttf\|\.gz\|\.html\|\.css\|\.h\|\.xml\|\.rgb\|\.gif\|\.wav\|\.ogg\|\.mp3\|\.po\|\.txt\|\.jpg\|\.jpeg\|\.bmp\|\.xcf\|\.mo\|\.rb\|\.py"`
	IFS=$'\n'
	for file in $packagefiles; do
		if (( $(file $file | grep -c 'ELF') != 0 )); then
			#  Is an ELF binary.
			libs=`readelf -d "${file}" | awk '/NEEDED.*\[.*\]/''{print $5}' | awk  '{ gsub(/\[|\]/, "") ; print  }'`
			for lib in ${libs} ; do
			# needed libs
				if [ -z `whereis ${lib} | awk '{print $2}'` ] ; then
					#  Missing lib.
					printf "\n\t ${RED}${file}${NC} needs ${REDUL}${lib}${NC}"
					BROKEN="true" # to avoid packages being listed in the brokenpkg array several times
				fi
			done
		fi
	done

	if [[ ${BROKEN} == "true" ]] ; then
		printf "\n"
		brokenpkgs="${brokenpkgs} ${package}"
	elif [[ ${BROKEN} == "false" ]] ; then
		printf " ${GREEN}ok${NC}\n"
	fi
done
echo "everything done."

brokenamount=`echo ${brokenpkgs} | wc -w`
if [[ ${brokenamount} = 0 ]] ; then
	echo "Apparently nothing to do."
elif  [[ ${brokenamount} = 1 ]] ; then
	echo -e "\n\n${brokenamount} package may need rebuild: \n${RED}${brokenpkgs}${NC}\n"
else
	echo -e "\n\n${brokenamount} packages may need rebuild: \n${RED}${brokenpkgs}${NC}\n"
fi

timeend
echo "Done after ${TD} seconds."
echo "This script may not be able to distinguish between required and optional dependencies!"
