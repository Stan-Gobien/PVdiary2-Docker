echo Demo config PVdiary2
sudo -u pvdiary2 /home/pvdiary2/bin/pvdiary --plugin=config --create-demo
sudo -u pvdiary2 /home/pvdiary2/bin/pvdiary --db --make-tables --init
sudo -u pvdiary2 /home/pvdiary2/bin/pvdiary --import --start-date=day1
sudo -u pvdiary2 /home/pvdiary2/bin/pvdiary --plugin=config --show-cfg
sudo -u pvdiary2 /home/pvdiary2/bin/pvdiary --export --info --expected --top

echo Autorun config
sed -i "s/\; exec_at_start\[] = \"pvdiary / exec_at_start\[] = \"pvdiary /g" /home/pvdiary2/etc/pvdiary.cfg
sed -i "s/\; exec_at_start\[] = \"toolbin / exec_at_start\[] = \"toolbin /g" /home/pvdiary2/etc/pvdiary.cfg

echo "Create file to indicate firstrun.sh has run"
sudo -u pvdiary2 touch /home/pvdiary2/.firstrunfinished
