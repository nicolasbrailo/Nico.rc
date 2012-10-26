dir="`find ~/Music/ -type d | sort -R| head -n1`"
mocp -c && mocp -a "$dir" && mocp --play
echo "Playing $dir"

