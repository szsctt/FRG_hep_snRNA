#!/bin/bash
set -e

# https://www.rocker-project.org/use/singularity/
# https://www.rc.virginia.edu/userinfo/howtos/rivanna/launch-rserver/

if [ ! -e scrna_rstudio.sif ]; then
	singularity pull ${PWD}/scrna_rstudio.sif docker://szsctt/r_scrna:6
	echo "finished pulling"
fi

TMPDIR=rstudio-tmp # your choice
mkdir -p $TMPDIR/tmp/rstudio-server
uuidgen > $TMPDIR/tmp/rstudio-server/secure-cookie-key
chmod 600 $TMPDIR/tmp/rstudio-server/secure-cookie-key
mkdir -p $TMPDIR/var/{lib,run}
touch ${TMPDIR}/var/run/test
mkdir -p ${TMPDIR}/home

printf 'provider=sqlite\ndirectory=/var/lib/rstudio-server\n' > database.conf


singularity exec \
    -B $(realpath ..):/usr/sco305/cap_zones_nuclear-preps \
    -B $TMPDIR/var/run:/var/run/rstudio-server \
    -B $TMPDIR/var/lib:/var/lib/rstudio-server \
    -B database.conf:/etc/rstudio/database.conf \
    -B $TMPDIR/tmp:/tmp \
    -B ${TMPDIR}/home:${HOME} \
    scrna_rstudio.sif \
    rserver --server-user=sco305 --www-port=8787



