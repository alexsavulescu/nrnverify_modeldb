#!/bin/sh
if test "$mdbtest" = "" ; then
  mdbtest=mdbtest
fi
for i in `find $mdbtest -name stderr -print` ; do
if grep 'make.*Error' $i > /dev/null ; then
	echo $i make failure
elif grep line $i | grep -v warning >/dev/null ; then
	echo $i failed in hoc
fi
done

