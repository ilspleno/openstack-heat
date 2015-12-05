#!/bin/bash

source brian-openrc.sh

sudo /opt/puppetlabs/bin/puppet cert clean oradb12.lab.thewoodruffs.org
heat stack-create -f oradb12.yml oradb-stack
