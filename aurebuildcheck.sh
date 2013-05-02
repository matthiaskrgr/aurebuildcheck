#!/bin/bash

timestart() {
	TS=`date +%s.%N`
}

timeend() {
	TE=`date +%s.%N`
	TD=`calc -p $TE - $TS`
}

echo "Running 'lddd'."
#echo "This may take some time..."

timestart

lddd

echo "Reading files and stuff..."
echo ""
LOCALPKGS=`pacman -Qqm`
DIR=`ls -tl /tmp/ | grep "ldd"  | head -n1 | awk '{print "/tmp/"$9}'`
BROKENPKGS=`cat "${DIR}"/possible-rebuilds.txt | awk '{print $2}'`
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

echo "lddd may not be able to distinguish between required and optional dependencies!"
echo "Removing files... ( ${DIR} )"
rm -r ${DIR}
