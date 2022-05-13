#!/bin/sh

cpDir=/opt/h5/trunk/filelist
svn up $cpDir

filebranch=filebranch
server_scene_dir=server_scene_dir 
ftpok=ftpok
ftptest=ftptest
ftpres=ftpres

\cp $cpDir"/"$filebranch ./
\cp $cpDir/$server_scene_dir ./
\cp $cpDir"/"$ftpok ./
\cp $cpDir"/"$ftptest ./
\cp $cpDir"/"$ftpres ./

#chmod 755 $filebranch $server_scene_dir $ftpok $ftptest $ftpres &&
svn ci -m 'cp脚本' $filebranch $server_scene_dir $ftpok $ftptest $ftpres --force-log && chmod 755 $filebranch $server_scene_dir $ftpok $ftptest $ftpres
