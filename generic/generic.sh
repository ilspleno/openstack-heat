#!/bin/bash

source ./brian-openrc.sh
VMNAME="generic"

nova delete $VMNAME

nova boot --flavor m1.small --image centos-6 --nic net-id=939b16fe-02a7-4437-a1e4-d26c6bc5929c,v4-fixed-ip=192.168.1.25 --security-group default --key-name jerry $VMNAME


while : ; do
  nova console-log $VMNAME
  sleep 10
done

#--nic <net-id=net-uuid,v4-fixed-ip=ip-addr,v6-fixed-ip=ip-addr,port-id=port-uuid>
