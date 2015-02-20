M=modeldb

ids="$*"
if test "$ids" = "" ; then
	ids=`(cd $M ; ls *.zip | sed 's/\.zip//')`
fi
echo $ids

for i in $ids ; do
	name=`unzip -t $M/$i.zip |sed -n '2s; *testing: *\([^/]*\)/.*;\1;p'`
#create the list of commands to run. from nrnziprun.dat if they exist
	sed -n "/^$name /,/^\$/ {
		/^$name /d
		p
	}" < nrnziprun.dat > tmp3
	x="`cat tmp3`"
	if test "$x" = "" ; then
echo "verify_graph_()
" >> tmp3
	fi
	rm -f script.tmp
	DoNotRun="no"
	if grep '//disregard' tmp3 > /dev/null ; then
		echo "$i $name `cat tmp3`"
	else
		if grep '//do not run' tmp3 > /dev/null ; then
			DoNotRun="yes"
		fi
		sed -n '/beginscript/,/endscript/p' tmp3 | sed '1d' | sed '$d' > script.tmp
		sh nrnziprun.sh $i $name driver.hoc tmp3 $DoNotRun
	fi
done

