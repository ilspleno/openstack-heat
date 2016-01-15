#!/bin/bash

source ~/devstack/openrc

#sudo /opt/puppetlabs/bin/puppet cert clean single12cR1.lab.thewoodruffs.org
heat stack-create -f single12cR1.yml single12cR1-stack
