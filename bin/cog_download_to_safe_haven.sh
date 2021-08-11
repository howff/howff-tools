#!/bin/bash
# Download, compress and transfer to hydra-vpn for import to the safe haven

verbose=1
prog="$0"
progpath=$(readlink -f "$prog")
progdir=$(dirname "$progpath")
log="${progdir}/$(basename $0).log"
downloaddir="${progdir}/tmp"
rsyncdir="${progdir}/COG-UK"
touch $log

# All executables in same dir as this program
export PATH=${PATH}:${progdir}

# Ensure that curl return code is not ignored when piped into xz
set -o pipefail


# ---------------------------------------------------------------------
# Append the message to the log file, and to the screen if verbose
log()
{
  msg="$1"
  echo "$(date) $msg" >> $log
  if [ $verbose -gt 0 ]; then echo "$(date) $msg"; fi
}


# ---------------------------------------------------------------------
# Report the error by logging it
error()
{
  msg="$1"
  # XXX increase verbose before logging?
  log "ERROR $msg"
  # XXX exit?
}


# ---------------------------------------------------------------------
# Get the URL,
#  only if newer than the existing file
#  compress it during transfer
#  check it for consistency
#  check the file size has increased
get()
{
  url="$1"

  # Get the mtime from the HTTP header and convert to time_t
  # Last-Modified: Wed, 07 Apr 2021 15:25:29 GMT
  lastmod=`curl -s -I "$url" | sed -n '/Last-Modified/s/Last-Modified: //p'`
  lastmod_t=`jday -H -t timet $lastmod`
  if [ "$lastmod" == "" ]; then
    error "Failed to get HTTP header for $url"
    return
  fi

  filename=`basename "$url"`
  tmpfile="${downloaddir}/tmp.${filename}.xz"
  realfile="${rsyncdir}/${filename}.xz"

  # See if file on webserver is newer, ignore if older
  if [ -f "$realfile" ]; then
    realfile_t=`stat -c %Y $realfile`
    if [ 0$realfile_t -gt 0$lastmod_t ]; then
      log "Not downloading $url as older than $realfile"
      return
    fi
  fi

  # Download to a temporary filename, compressed
  log "Downloading $url to $tmpfile"
  curl -s "$url" | xz -T 32 -c > ${tmpfile}
  rc=$?
  if [ $rc -ne 0 ]; then
    error "downloading $url"
    return
  fi

  # Check consistency
  if expr match "$realfile" ".*fasta.*" > /dev/null; then
    log "Checking fasta format $tmpfile"
    ./check_fasta.py "$tmpfile"
    if [ $? -ne 0 ]; then
      error "Check failed $tmpfile"
      return
    fi
  fi
  if expr match "$realfile" ".*newick.*" > /dev/null; then
    log "Checking newick format $tmpfile"
    ./check_newick.py "$tmpfile"
    if [ $? -ne 0 ]; then
      error "Check failed $tmpfile"
      return
    fi
  fi
  if expr match "$realfile" ".*csv.*" > /dev/null; then
    log "Checking csv format $tmpfile"
    ./check_csv.py "$tmpfile"
    if [ $? -ne 0 ]; then
      error "Check failed $tmpfile"
      return
    fi
  fi

  # If file is larger than previous then keep it
  prevsize=$(stat -c %s $realfile)
  newsize=$(stat -c %s $tmpfile)
  if [ 0$newsize -gt 0$presize ]; then
    log "New file is larger so keep it"
    mv "$tmpfile" "$realfile"
    if [ $? -ne 0 ]; then
      error "Cannot move $tmpfile to $realfile"
      return
    fi
    # Set the timestamp of the new file to be the same as on the webserver
    log "Set timestamp to $lastmod on $realfile"
    touch -d "$lastmod" "$realfile"
    if [ $? -ne 0 ]; then
      error "Failed to set timestamp to $lastmod on $realfile"
      return
    fi
  else
    log "New file is smaller so discard it"
  fi
}


upload_all()
{
  log "Upload $rsyncdir"
  # Start from its parent directory and upload the directory itself to hydra-vpn
  cd "${rsyncdir}/.."
  sshpass -f ~/.hydra-vpn rsync -e ssh -av `basename "${rsyncdir}"` abrooks@hydra-vpn.epcc.ed.ac.uk:/home/node1/smi/
}


log "Starting"
mkdir -p "${downloaddir}"
mkdir -p "${rsyncdir}"
get "https://cog-uk.s3.climb.ac.uk/phylogenetics/latest/cog_all.fasta"
get "https://cog-uk.s3.climb.ac.uk/phylogenetics/latest/cog_alignment.fasta"
get "https://cog-uk.s3.climb.ac.uk/phylogenetics/latest/cog_unmasked_alignment.fasta"
get "https://cog-uk.s3.climb.ac.uk/phylogenetics/latest/cog_global_tree.newick"
get "https://cog-uk.s3.climb.ac.uk/phylogenetics/latest/cog_metadata.csv"
upload_all
log "Finished"
