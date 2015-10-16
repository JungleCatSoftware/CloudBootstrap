#!/bin/bash
export maintainer=JungleCatSoftware
export repo=CloudBootstrap
export release=0.0.2
export logdir=/var/log/${maintainer}/${repo}
targetdir=/opt/${maintainer}
mkdir -p ${logdir} &&\
mkdir -p ${targetdir} &&\
curl -L https://github.com/${maintainer}/${repo}/archive/${release}.tar.gz |\
tar -xz -C ${targetdir} &&\
mv ${targetdir}/${repo}-${release} ${targetdir}/${repo} &&\
${targetdir}/${repo}/scripts/run 2>&1 | tee ${logdir}/CloudBootstrap.log
