limit=0
while true
do
  limit=`echo 10000000+$limit|bc`
  a=$(printf %10000000s |tr " " "=")$a
  x=`expr $limit % 100000` 
  if [[ $x -eq 0 ]]; then
  	echo `expr \( $limit / 1048576 \)`
	#echo ${#a}
  fi
done
