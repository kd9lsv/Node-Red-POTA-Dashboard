#!/bin/bash

clear
# Update RPI
echo "Updating and Upgrading your Pi to newest standards"
sudo apt update -qq > /dev/null && sudo apt full-upgrade -qq -y > /dev/null && sudo apt clean > /dev/null
wait

#Install Node-Red
bash <(curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered) <<!
y
y
!
wait

# Start NodeRed
sudo systemctl start nodered.service
sudo systemctl enable nodered.service

# Install git & Sqlite3
sudo apt-get install git sqlite3 -qq > /dev/null
wait

# Configure SQLITE
cd /home/pi
sqlite3 pota<< !
CREATE TABLE validparksdesignator(
  "designator" TEXT type UNIQUE
);
CREATE TABLE designatoralert(
 "designator" TEXT type UNIQUE
);
CREATE TABLE callsignalert(
 "callsign" TEXT type UNIQUE
);
CREATE TABLE parkalert(
 "park" TEXT type UNIQUE
);
CREATE TABLE huntedparks(
  "DXCCEntity" TEXT,
  "Location" TEXT,
  "HASC" TEXT,
  "Reference" TEXT type UNIQUE,
  "ParkName" TEXT,
  "FirstQSODate" TEXT,
  "QSOs" INTEGER
);
CREATE TABLE locdescalert(
 "locdesc" TEXT type UNIQUE
);
.exit
!

#configure NodeRed
node-red-stop
wait
cd /home/pi/.node-red
npm install @node-red-contrib-themes/theme-collection
mkdir projects
cd projects
echo "Cloning the Node-Red Dashboard"
git clone https://github.com/kylekrieg/Node-Red-POTA-Dashboard.git
cd Node-Red-POTA-Dashboard
npm --prefix ~/.node-red/ install ~/.node-red/projects/Node-Red-POTA-Dashboard/
curl -o settings.js https://gist.githubusercontent.com/kd9lsv/b114c87eb3f30b4d3cc53009d486978f/raw/c84a38d999ef8c4562237b531cfc4bcd5f26efab/settings.js

sudo systemctl restart nodered.service
HOSTIP=`hostname -I | cut -d ' ' -f 1`
    if [ "$HOSTIP" = "" ]; then
        HOSTIP="127.0.0.1"
    fi
echo "Node Red has Completed. head to http://$HOSTIP:1880 ".
