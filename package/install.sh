#!/bin/bash

yum install -y -e0 libxml2

cp -R data/* "${cw_ROOT}"
