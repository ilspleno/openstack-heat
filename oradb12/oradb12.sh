#!/bin/bash


function id_of {
  echo `cinder list | grep $1 | cut -f2 -d " "`
}


source brian-openrc.sh

nova delete oradb12
sleep 5

nova boot --flavor m1.small --image centos-6 --nic net-id=939b16fe-02a7-4437-a1e4-d26c6bc5929c --nic net-id=31675bfc-fc1c-4c8f-a50b-ad51ccb7b3e0,v4-fixed-ip=172.16.1.3 --security-group default --key-name "brian mac" oradb12 --user-data userdata-oradb12

echo "Dropping volumes"
cinder delete ora12_ocrvote1
cinder delete ora12_ocrvote2
cinder delete ora12_ocrvote3

cinder delete ora12_data1
cinder delete ora12_data2
cinder delete ora12_reco1
cinder delete ora12_reco2

sleep 30

echo "Creating volumes"
cinder create --name ora12_ocrvote1 --allow-multiattach 3
cinder create --name ora12_ocrvote2 --allow-multiattach 3
cinder create --name ora12_ocrvote3 --allow-multiattach 3

cinder create --name ora12_data1 --allow-multiattach 10
cinder create --name ora12_data2 --allow-multiattach 10

cinder create --name ora12_reco1 --allow-multiattach 10
cinder create --name ora12_reco2 --allow-multiattach 10


sleep 30

echo "Attaching volumes"
nova volume-attach oradb12 `id_of ora12_ocrvote1`
nova volume-attach oradb12 `id_of ora12_ocrvote2`
nova volume-attach oradb12 `id_of ora12_ocrvote3`

nova volume-attach oradb12 `id_of ora12_data01`
nova volume-attach oradb12 `id_of ora12_data02`

nova volume-attach oradb12 `id_of ora12_reco01`
nova volume-attach oradb12 `id_of ora12_reco02`

sudo /opt/puppetlabs/bin/puppet cert clean oradb12.lab.thewoodruffs.org

while : ; do
  nova console-log oradb12
  sleep 5
done

#--nic <net-id=net-uuid,v4-fixed-ip=ip-addr,v6-fixed-ip=ip-addr,port-id=port-uuid>
