#!/bin/sh

if test "$mdbtest" = "" ; then
  mdbtest=mdbtest
fi
  
models="`sed 's/^[0-9]*//' map.txt`"

missing=""
small=""
for i in $models ; do
	if test -f $mdbtest/$i/gout ; then
		true
	else
		missing="$missing $i"
		echo $i
	fi
done
echo ""
echo "small size gout"
small=`find $mdbtest -name gout -size -300c -print | \
  sed "s;$mdbtest/\([^/]*\)/gout;\1;"|sort`
echo $small

for i in $small ; do
  grep $i map.txt
done

echo ""
echo "missing gout"
for i in $missing ; do
  grep $i map.txt
done
