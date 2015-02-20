#!/bin/sh
if test "$standard" = "" ; then
 standard=Standard
fi
if test "$mdbtest" = "" ; then
 mdbtest=mdbtest
fi

a=`pwd`

if [ $# -eq 1 ] ; then
	files=$1/gout
else
	cd $standard
	files=`find . -name gout -print`
	cd $a
	cd $mdbtest
	nfiles=`find . -name gout -print`
	cd ..
fi
for i in $files ; do
	if cmp $standard/$i $mdbtest/$i ; then
		true;
	else
		echo $i
	fi
done
for i in $nfiles ; do
	if test ! -f $standard/$i ; then
		echo "$standard/$i does not exist"
	fi
done

