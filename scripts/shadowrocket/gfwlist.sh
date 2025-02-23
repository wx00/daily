#!/bin/bash -e

CUR_DIR=$(pwd)
TMP_DIR=$(mktemp -d /tmp/shadowrocket.XXXXXX)

DIST_FILE="dist/shadowrocket/gfwlist.conf"
DIST_DIR="$(dirname $DIST_FILE)"
DIST_NAME="$(basename $DIST_FILE)"

function fetch_data() {
  cd $TMP_DIR

  cp $CUR_DIR/template/shadowrocket/gfwlist.template .
  cp $CUR_DIR/dist/gfwlist/gfwlist.txt .

  cd $CUR_DIR
}

function gen_gfwlist_config() {
  cd $TMP_DIR

  local gfwlist_tmp="gfwlist.tmp"

  # generate content
  sed -e 's/^/DOMAIN-SUFFIX,/' -e 's/$/,PROXY,force-remote-dns/' gfwlist.txt > $gfwlist_tmp

  # date
  cat <<- EOF > $DIST_NAME
	#
	# Update: $(date +'%Y-%m-%d %T')
	#

	EOF

  # replace content
  sed "s/___GFWLIST_DOMAINS_PLACEHOLDER___/cat $gfwlist_tmp/e" gfwlist.template >> $DIST_NAME

  cd $CUR_DIR
}

function dist_release() {
  mkdir -p $DIST_DIR
  cp $TMP_DIR/$DIST_NAME $DIST_FILE
}

function clean_up() {
  rm -r $TMP_DIR
  echo "[shadowrocket/gfwlist]: OK."
}

fetch_data
gen_gfwlist_config
dist_release
clean_up
