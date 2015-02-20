M=modeldb

ids=`(cd $M ; ls *.zip | sed 's/\.zip//')`

rm -f tmp1
for i in $ids ; do
	name=`unzip -t $M/$i.zip |sed -n '2s; *testing: *\([^/]*\)/.*;\1;p'`
	echo "$i $name" >> tmp1
done
sort -k2,2 tmp1 > map.txt
rm tmp1
