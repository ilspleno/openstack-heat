#!/bin/bash

source ~/brian-openrc.sh

sudo /opt/puppetlabs/bin/puppet cert clean rac12cr11.lab.thewoodruffs.org
sudo /opt/puppetlabs/bin/puppet cert clean rac12cr12.lab.thewoodruffs.org
sudo /opt/puppetlabs/bin/puppet cert clean rac12cr13.lab.thewoodruffs.org
OCRVOTE1=`cinder create --allow-multiattach --name rac12cr1ocrvote1 3 | grep " id " | awk ' { print $4; } '`
OCRVOTE2=`cinder create --allow-multiattach --name rac12cr1ocrvote2 3 | grep " id " | awk ' { print $4; } '`
OCRVOTE3=`cinder create --allow-multiattach --name rac12cr1ocrvote3 3 | grep " id " | awk ' { print $4; } '`
DISK001=`cinder create --allow-multiattach --name rac12cr1disk001 10 | grep " id " | awk ' { print $4; } '`
DISK002=`cinder create --allow-multiattach --name rac12cr1disk002 10 | grep " id " | awk ' { print $4; } '`
DISK003=`cinder create --allow-multiattach --name rac12cr1disk003 10 | grep " id " | awk ' { print $4; } '`
DISK004=`cinder create --allow-multiattach --name rac12cr1disk004 10 | grep " id " | awk ' { print $4; } '`
DISK005=`cinder create --allow-multiattach --name rac12cr1disk005 10 | grep " id " | awk ' { print $4; } '`

heat stack-create -f rac.yml -P "ocrvote1=$OCRVOTE1;ocrvote2=$OCRVOTE2;ocrvote3=$OCRVOTE3;disk001=$DISK001;disk002=$DISK002;disk003=$DISK003;disk004=$DISK004;disk005=$DISK005" racstack
