#!/bin/bash -e

function set_time()
{
  timestamp=$(git --git-dir=${GITDIR} log -n1 --pretty=format:%at $2 -- $1)
  file_time=$(date -d @${timestamp} '+%Y%m%d%H%M.%S')
  touch -t ${file_time} $1
}

GITDIR=$1
tag=$2
[ "X$1" = "X" -o "X$2" = "X" ] && exit 1

let NUM_PROC=$(nproc)*2
WORKSPACE="${WORKSPACE-$PWD}"
wget -q https://github.com/cms-sw/cmssw/archive/${tag}.tar.gz
tar -xzf ${tag}.tar.gz
rm -f ${tag}.tar.gz
mv cmssw-${tag} ${tag}
cd ${WORKSPACE}/${tag}

find . -type f | sed 's|^./||' > ${WORKSPACE}/files.txt
TFILES=$(cat ${WORKSPACE}/files.txt | wc -l)
NFILE=0
for file in $(cat ${WORKSPACE}/files.txt) ; do
  while [ $(jobs -p | wc -l) -ge ${NUM_PROC} ] ; do sleep 0.001 ; done
  let NFILE=${NFILE}+1
  echo "[${NFILE}/${TFILES}] $file"
  set_time $file $tag &
done
wait
