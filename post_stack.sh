#!/bin/bash

source ~/devstack/openrc

openstack keypair create --public-key keys/mac-key mac-key
openstack keypair create --public-key keys/server1-key server1-key
