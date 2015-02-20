#!/bin/sh
#using map.txt, create a new nrnziprun.dat preserving the exisiting methods

models="`sed 's/ /@@@/' map.txt`"
rm -f tmp3
for i in $models ; do
  modelname="`echo $i | sed 's/.*@@@//'`"
  modelid="`echo $i | sed 's/@@@.*//'`"
  echo $modelname $modelid
  echo $modelname $modelid >> tmp3
  if grep -q "^$modelname " < nrnziprun.dat ; then
	  sed -n "/^$modelname /,/^\$/ {
  		/^$modelname /d
	  	p
	  }" < nrnziprun.dat >> tmp3
  else
  	echo "" >> tmp3
  fi
done

mv tmp3 nrnziprun.dat
