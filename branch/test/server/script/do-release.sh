#!/bin/bash
#################################################################
#
# Description       : release
#
#################################################################
cd ../database &&
svn up &&
chmod 755 db_version &&
./db_version drop release &&
./db_version update release &&
cd ../script &&
./helper.sh auto &&
./do-package.sh
