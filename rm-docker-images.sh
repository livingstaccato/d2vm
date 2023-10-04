#!/bin/sh

docker image rm -f $(docker image ls | awk '{ print $3 }')
