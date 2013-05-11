#!/bin/bash

export LANG=C



# functions and variables #
RED='\e[1;31m'
GREEN='\e[1;32m'
REDUL='\e[4;31m'
WHITEUL='\e[4;02m'
NC='\e[0m'
brokenpkgs=""
autoignored=""


timestart() {
	TS=`date +%s`
}

timeend() {
    TE=`date +%s`
    let TD="$TE-$TS"
}

# the core of the script #

timestart # start timer

localpackages=`pacman -Qqm`
localpackagesamount=`echo ${localpackages} | wc -w`
# ${localpackages} > 0 since aurebuildcheck in aur
if  [[ ${localpackagesamount} = 1 ]] ; then
	echo -e "Checking ${localpackagesamount} local package...\n"
else
	echo -e "Checking ${localpackagesamount} local packages...\n"
fi


for package in $localpackages ; do
	BROKEN="false"
    printf "checking ${package}..."
    PkgArch=`pacman -Qi $package | grep "Architecture" | awk '{print $3}' -`
    if [[ ${PkgArch} == 'any' ]]; then  #Skip package whose architecture is any
        autoignored="${autoignored} ${package}"
        printf " ${GREEN}skiped${NC}\n"
        continue
    fi
	packagefiles=`pacman -Qql $package | grep -v "\/$\|\.a\|\.png\|\.la\|\.ttf\|\.gz\|\.html\|\.css\|\.h\|\.xml\|\.rgb\|\.gif\|\.wav\|\.ogg\|\.mp3\|\.po\|\.txt\|\.jpg\|\.jpeg\|\.bmp\|\.xcf\|\.mo\|\.rb\|\.py"`
	IFS=$'\n'
	for file in $packagefiles; do # check the files
		if (( $(file $file | grep -c 'ELF') != 0 )); then
			#  Is an ELF binary.
			libs=`readelf -d "${file}" | awk '/NEEDED.*\[.*\]/''{print $5}' | awk  '{ gsub(/\[|\]/, "") ; print  }'`
            filepath=`echo ${file} | sed -e "s|/[^/]*$||" ` #get current file's path
			for lib in ${libs} ; do
			# needed libs
				if [ -z `whereis ${lib} | awk '{print $2}'` ] && [ -z `find ${filepath} -type f -name ${lib}` ] ; then #check local libs and bundled libs
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
echo -e "\n\n${brokenamount} package(s) may need rebuild: \n${RED}${brokenpkgs}${NC}\n"
autoignoredamount=`echo ${autoignored} | wc -w`
echo -e "\n${autoignoredamount} package(s) auto ignored: \n${GREEN}${autoignored}${NC}\n"

timeend
echo "Done after ${TD} seconds."
echo "This script may not be able to distinguish between required and optional dependencies!"
