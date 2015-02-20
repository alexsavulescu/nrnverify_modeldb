#!/bin/sh
# 1st arg is the model id, i.e. modeldb/$1.zip is the model
# 2nd arg is the model name. The zip file will create a directory with that name.
# 3rd arg is the name of the primary driver body, driver.hoc
# 4th arg is a file to be concatenated to the driver.
# 5th arg is "yes" or "no" with regard to DoNotRun
# the drive will be prepended with a spec of
# verify_dir_ which is the directory the driver should write to if needed.
# i.e the tmp/basename directory

if test "$mdbtest" = "" ; then
  mdbtest=mdbtest
fi

dir="`pwd`/$mdbtest/$2"

if test "$SYSTEMDRIVE" = "C:" ; then
	RM="rm"
	cygwin=yes
	N=/cygdrive/c/nrn61
	NEURONHOME=$N
	export N
	export NEURONHOME
	PATH=$N/bin:$PATH
	export PATH
else
	ARCH=`which nrniv | sed 's;.*/\([^/]*\)/bin/nrniv;\1;'`
	RM=/bin/rm
fi

$RM -r -f $dir
mkdir $dir
unzip -d $dir modeldb/$1.zip

driver=$dir/driver.hoc

echo "
strdef verify_dir_
verify_dir_ = \"$dir\"
" > $driver

if test -s script.tmp ; then
  mv script.tmp $dir
  (cd $dir/$2 ; sh ../script.tmp)
fi

cat $3 >> $driver
cat $4 >> $driver
moddirs="`sed -n '1s;^//moddir;;p' < $4`"

cd $dir

# make a file for communication with neuron

if [ -r mosinit.hoc ] ; then
	first=./mosinit.hoc
else
	first=`find . -name mosinit.hoc -print |sort|sed -n 1p`
fi

if [ -z "$first" ] ; then
	echo "Missing the mosinit.hoc file"
	exit 1
fi
startdir=`dirname $first`

if test "$moddirs" = "" ; then
	moddirs="`sed -n '1s;^//moddir;;p' < $first | tr -d '\r'`"
fi
echo "moddirs = |$moddirs|"
echo "startdir = |$startdir|"
(cd $startdir
if test "$moddirs" != "" ; then
	modfiles='yes'
else
	modfiles="`ls *.mod 2>/dev/null`"
fi

firstarg=mosinit.hoc
if test "$5" = "yes" ; then
	firstarg=$dir/quit.hoc
	echo "quit()" > $dir/quit.hoc
fi
if test "$cygwin" = "yes"  ; then
	if test "$modfiles" != "" ; then
		sh $N/bin/mknrndll $moddirs
	fi
	nrniv $firstarg $driver << here
quit()
here
else
	if [ "$modfiles" ] ; then
		nrnivmodl $moddirs
		time ./${ARCH}/special $firstarg $driver
	else
		time nrniv $firstarg $driver
	fi
fi
) > stdout 2>stderr

