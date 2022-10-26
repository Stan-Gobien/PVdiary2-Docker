# Demo config PVdiary2
#sudo -u pvdiary2 pvdiary --plugin=config --create-demo
#sudo -u pvdiary2 pvdiary --db --make-tables --init
#sudo -u pvdiary2 pvdiary --import --start-date=day1
#sudo -u pvdiary2 pvdiary --plugin=config --show-cfg
#sudo -u pvdiary2 pvdiary --plugin=config --show-cfg
#sudo -u pvdiary2 pvdiary --export --info --expected --top


# Rclone, to difficult to include at build time, will have to create at RUN time
#ENV TYPE=ftp
#ENV HOST=
#ENV USER=
#ENV PASS=
#RUN sudo -u pvdiary2 rclone config create pvdiary ftp host www.gobien.be user xxxx pass yyyyy
