#!/bin/bash

timestart() {
	TS=`date +%s.%N`
}

timeend() {
	TE=`date +%s.%N`
	TD=`calc -p $TE - $TS`
}

echo "Running 'findbrokenpkgs'."
echo "This may take some time..."

timestart

LOCALPKGS=`pacman -Qqm`
BROKENPKGS=`findbrokenpkgs -q -nc | sed '3q;d'` # maybe we can run findbrokenpkgs on only the sources of pacman -Qqm ?
NEEDSREBUILD=""

for BROKENPKG in ${BROKENPKGS}; do
	for LOCALPKG in ${LOCALPKGS} ; do
		if [[ "${BROKENPKG}" == "${LOCALPKG}" ]] ; then
			NEEDSREBUILD="${NEEDSREBUILD} ${LOCALPKG}"
		fi
	done
done

if [ -z ${NEEDSREBUILD} ] ; then
	echo "All local packages seem ok."
else
	echo "Local packages that may need rebuild:"
	echo "${NEEDSREBUILD}"
fi

timeend
TIME=`awk 'match($0,/[0-9]*.[0-9]{5}/) {print substr($0,RSTART,RLENGTH)}' <( echo "${TD}" )`

echo "Done after ${TIME} seconds."

echo "Some/all breakages may be OK - findbrokenpkgs cannot distinguish between required and optional dependencies. See http://bbs.archlinux.org/viewtopic.php?id=13882 "
