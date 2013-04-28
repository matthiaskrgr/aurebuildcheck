#!/bin/bash

echo "Running 'findbrokenpkgs'."
echo "This may take some time..."

LOCALPKGS=`pacman -Qqm`
BROKENPKGS=`findbrokenpkgs -q -nc | sed '3q;d'`
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
