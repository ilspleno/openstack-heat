#!/bin/bash

source brian-openrc.sh

sudo /opt/puppetlabs/bin/puppet cert clean node1.lab.thewoodruffs.org
sudo /opt/puppetlabs/bin/puppet cert clean node2.lab.thewoodruffs.org
sudo /opt/puppetlabs/bin/puppet cert clean node3.lab.thewoodruffs.org
heat stack-create -f rac12c.yml rac12c
