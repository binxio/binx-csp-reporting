#!/bin/bash
DATE=`date '+%Y%m%d%H%M%S'`
echo "VERSION='1.0.0'" > lambdas/version.py
echo "BUILT_AT='$DATE'" >> lambdas/version.py
