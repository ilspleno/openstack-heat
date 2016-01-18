#!/bin/bash

FN="../freenas.rb"

source ~/devstack/openrc

# Clean up old iSCSI disks
$FN -a delete -p single12cR1 -n ocrvote01 
$FN -a delete -p single12cR1 -n ocrvote02 
$FN -a delete -p single12cR1 -n ocrvote03 
$FN -a delete -p single12cR1 -n disk001 
$FN -a delete -p single12cR1 -n disk002 
$FN -a delete -p single12cR1 -n disk003 
$FN -a delete -p single12cR1 -n disk004 
$FN -a delete -p single12cR1 -n disk005 

if [ "$1" == "cleanup" ]; then
	echo "Cleanup complete"
	exit
fi

# Create new iSCSI disks for instance
$FN -a create -p single12cR1 -n ocrvote01 -s 3GB
$FN -a create -p single12cR1 -n ocrvote02 -s 3GB
$FN -a create -p single12cR1 -n ocrvote03 -s 3GB
$FN -a create -p single12cR1 -n disk001 -s 10GB
$FN -a create -p single12cR1 -n disk002 -s 10GB
$FN -a create -p single12cR1 -n disk003 -s 10GB
$FN -a create -p single12cR1 -n disk004 -s 10GB
$FN -a create -p single12cR1 -n disk005 -s 10GB

sudo ssh server2 puppet cert clean single12cR1.thewoodruffs.org
heat stack-create -f single12cR1.yml single12cR1-stack

