# to make resilent against models that have the same name toplevel folder a subfolder
# with the name of the object id is provided
M=modeldb

ids="$*"
if test "$ids" = "" ; then
	ids=`(cd $M ; ls *.zip | sed 's/\.zip//')`
fi
echo $ids
cd $M
for i in $ids ; do
        #echo unzipping $i
	mkdir $i
	cd $i
	pwd
	unzip ../$i.zip
        cd ..
done


