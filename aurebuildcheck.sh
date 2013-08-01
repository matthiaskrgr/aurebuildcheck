#!/bin/bash

export LANG=C



# functions and variables #
RED='\e[1;31m'
GREEN='\e[1;32m'
REDITALIC='\e[3;31m'
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

# the core of the script #

timestart # start timer

if [[ -z "$@" ]] ; then
	localpackages=`pacman -Qqm`
else
	localpackages="$@"
fi

localpackagesamount=`echo ${localpackages} | wc -w`
# ${localpackages} > 0 since aurebuildcheck in aur
if  [[ ${localpackagesamount} = 1 ]] ; then
	echo -e "Checking ${localpackagesamount} package...\n"
else
	echo -e "Checking ${localpackagesamount} packages...\n"
fi


for package in $localpackages ; do
	if [ `pacman -Qq $package >&1` ] ; then
		BROKEN="false"
		printf "checking ${package}..."
		# sort out some files which are not supposed to be ELF files anyway.
		packagefiles=`pacman -Qql $package | grep -v "\/$\|\.a\|\.png\|\.la\|\.ttf\|\.gz\|\.html\|\.css\|\.h\|\.xml\|\.rgb\|\.gif\|\.wav\|\.ogg\|\.mp3\|\.po\|\.txt\|\.jpg\|\.jpeg\|\.bmp\|\.xcf\|\.mo\|\.rb\|\.py\|\.lua\|\.config\|\.svg\|\.desktop\|\.conf\|\.pdf\|\.cfg"`
		IFS=$'\n'
		for file in $packagefiles; do # check the files
			if (( $(file $file | grep -c 'ELF') != 0 )); then
			# is an ELF binary
				lib=`ldd $file |& grep "\ =>\ not\ found" | awk '{print $1}'`
				if [ ! -z ${lib} ] ; then
					printf "\n\t ${RED}${file}${NC} needs ${REDITALIC}${lib}${NC}"
					BROKEN="true" # to avoid packages being listed in the brokenpkg array several times
				fi
				lib=""
			fi
		done

		if [[ ${BROKEN} == "true" ]] ; then
			printf "\n"
			brokenpkgs="${brokenpkgs} ${package}"
		elif [[ ${BROKEN} == "false" ]] ; then
			printf " ${GREEN}ok${NC}\n"
		fi
	else
		echo -e "${RED}Warning: '${package}' not found!${NC}"
	fi
done
echo "everything done."

brokenamount=`echo ${brokenpkgs} | wc -w`
if  [[ ${brokenamount} = 1 ]] ; then
	echo -e "\n\n${brokenamount} package may need rebuild: \n${RED}${brokenpkgs}${NC}"
else
	echo -e "\n\n${brokenamount} packages may need rebuild: \n${RED}${brokenpkgs}${NC}"
fi

timeend
echo "Done after ${TD} seconds."
echo "This script may not be able to distinguish between required and optional dependencies!"
