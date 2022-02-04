#!/bin/bash
set -e

# https://www.rocker-project.org/use/singularity/
# https://www.rc.virginia.edu/userinfo/howtos/rivanna/launch-rserver/

module load singularity


if [ ! -e scrna_rstudio.sif ]; then
	ssh petrichor-login "module load singularity; singularity pull ${PWD}/scrna_rstudio.sif docker://szsctt/r_scrna:4"
fi

TMPDIR=rstudio-tmp # your choice
mkdir -p $TMPDIR/tmp/rstudio-server
uuidgen > $TMPDIR/tmp/rstudio-server/secure-cookie-key
chmod 600 $TMPDIR/tmp/rstudio-server/secure-cookie-key
mkdir -p $TMPDIR/var/{lib,run}
touch ${TMPDIR}/var/run/test
mkdir -p ${TMPDIR}/home

printf 'provider=sqlite\ndirectory=/var/lib/rstudio-server\n' > database.conf

firefox &

singularity exec \
    -B $TMPDIR/var/run:/var/run/rstudio-server \
    -B $TMPDIR/var/lib:/var/lib/rstudio-server \
    -B database.conf:/etc/rstudio/database.conf \
    -B $TMPDIR/tmp:/tmp \
    -B ${TMPDIR}/home:${HOME} \
    scrna_rstudio.sif \
    rserver --www-address=127.0.0.4 --server-user=sco305 --www-port=8787



