#!/bin/bash
set -e

# https://www.rocker-project.org/use/singularity/
# https://www.rc.virginia.edu/userinfo/howtos/rivanna/launch-rserver/

if [ ! -e scrna_rstudio.sif ]; then
	singularity pull ${PWD}/scrna_rstudio.sif docker://szsctt/r_scrna:6
	echo "finished pulling"
fi

cd ..

TMPDIR=rstudio-tmp # your choice
mkdir -p $TMPDIR/tmp/rstudio-server
uuidgen > $TMPDIR/tmp/rstudio-server/secure-cookie-key
chmod 600 $TMPDIR/tmp/rstudio-server/secure-cookie-key
mkdir -p $TMPDIR/var/{lib,run}
touch ${TMPDIR}/var/run/test
mkdir -p ${TMPDIR}/home

printf 'provider=sqlite\ndirectory=/var/lib/rstudio-server\n' > "${TMPDIR}/database.conf"


singularity exec \
    -B $TMPDIR/var/run:/var/run/rstudio-server \
    -B $TMPDIR/var/lib:/var/lib/rstudio-server \
    -B $TMPDIR/database.conf:/etc/rstudio/database.conf \
    -B $TMPDIR/tmp:/tmp \
    scripts/scrna_rstudio.sif \
    rserver --server-user=$(whoami) --www-port=8888


#    -B ${TMPDIR}/home:${HOME} \
#    -B $(realpath ..):$(realpath ..) \

