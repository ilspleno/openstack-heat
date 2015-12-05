#!/bin/bash


VMNAME=puppet
source ./brian-openrc.sh

nova delete puppet

sleep 5

nova boot --flavor m1.medium --image centos-6 --nic net-id=939b16fe-02a7-4437-a1e4-d26c6bc5929c --nic net-id=31675bfc-fc1c-4c8f-a50b-ad51ccb7b3e0,v4-fixed-ip=172.16.1.2 --security-group default --key-name "brian mac" $VMNAME --user-data userdata-${VMNAME}


while : ; do
  nova console-log $VMNAME
  sleep 5
done

#--nic <net-id=net-uuid,v4-fixed-ip=ip-addr,v6-fixed-ip=ip-addr,port-id=port-uuid>
