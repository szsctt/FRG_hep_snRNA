#!/bin/bash
set -e

# https://www.rocker-project.org/use/singularity/
# https://www.rc.virginia.edu/userinfo/howtos/rivanna/launch-rserver/

module load singularity


if [ ! -e scrna_rstudio.sif ]; then
	ssh pearcey-login "module load singularity; singularity pull ${PWD}/scrna_rstudio.sif docker://szsctt/r_scrna:3"
fi

TMPDIR=rstudio-tmp # your choice
mkdir -p $TMPDIR/tmp/rstudio-server
uuidgen > $TMPDIR/tmp/rstudio-server/secure-cookie-key
chmod 600 $TMPDIR/tmp/rstudio-server/secure-cookie-key
mkdir -p $TMPDIR/var/{lib,run}

printf 'provider=sqlite\ndirectory=/var/lib/rstudio-server\n' > database.conf

firefox &

module load singularity
singularity exec \
    -B $TMPDIR/var/lib:/var/lib/rstudio-server \
    -B $TMPDIR/var/run:/var/run/rstudio-server \
    -B database.conf:/etc/rstudio/database.conf \
    -B $TMPDIR/tmp:/tmp \
    scrna_rstudio.sif \
    rserver --www-address=127.0.0.1 --server-user=sco305 



