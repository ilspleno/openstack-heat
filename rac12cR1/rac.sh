#!/bin/bash

source ~/devstack/openrc

heat stack-create -f rac.yml racstack
