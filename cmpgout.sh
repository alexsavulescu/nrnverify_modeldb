#!/bin/sh
if test "$standard" = "" ; then
  standard=Standard
fi
if test "$mdbtest" = "" ; then
  mdbtest=mdbtest
fi
  
sed "
s,mdbtest,$mdbtest,
s,Standard,$standard,
" showgout.hoc > _showgout.hoc

if [ $# -eq 1 ] ; then
	files=$1/gout
else
	cd $standard
	files=`find . -name gout -print`
	cd ..
fi

if test "$SYSTEMDRIVE" = "C:" ; then
	N=/cygdrive/c/nrn61
	NEURONHOME=$N
	export N
	export NEURONHOME
	PATH=$N/bin:$PATH
	export PATH
fi

for i in $files ; do
	echo $i > temp
	if cmp $standard/$i $mdbtest/$i ; then
		true;
	else
		echo $i
		if test "$SYSTEMDRIVE" = "C:" ; then
			nrniv _showgout.hoc
		else
			nrngui _showgout.hoc
		fi
	fi
done

