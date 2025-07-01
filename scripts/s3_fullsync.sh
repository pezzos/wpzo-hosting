#!/bin/bash
SERVERDIR="/path/to/servers"
WORKDIR="/path/to/work"


while IFS="" read -r p || [ -n "$p" ]
do
  DOMAIN_FULL=$(echo $p | cut -f1 -d: )
  DOMAIN=$(echo "$DOMAIN_FULL" | cut -f2- -d.)
  SUB=$(echo "$DOMAIN_FULL" | cut -f1 -d.)
  [ -d "$SERVERDIR/$DOMAIN/$SUB/static" ] && \
  rm -rf $SERVERDIR/$DOMAIN/$SUB/static/wp-json/ \
  $SERVERDIR/$DOMAIN/$SUB/static/author/ \
  $SERVERDIR/$DOMAIN/$SUB/static/comments/ \
  $SERVERDIR/$DOMAIN/$SUB/static/wp-json/ \
  $SERVERDIR/$DOMAIN/$SUB/static/wp-admin/ && \
  aws s3 sync --quiet --delete $SERVERDIR/$DOMAIN/$SUB/static s3://$DOMAIN_FULL --exclude "$SERVERDIR/$DOMAIN/$SUB/static/.git/*" --exclude "$SERVERDIR/$DOMAIN/$SUB/static/.github/*" --exclude "$SERVERDIR/$DOMAIN/$SUB/static/wp-json/*" --exclude "$SERVERDIR/$DOMAIN/$SUB/static/author/*" --exclude "$SERVERDIR/$DOMAIN/$SUB/static/comments/*" --exclude "$SERVERDIR/$DOMAIN/$SUB/static/wp-admin/*"
done < ${WORKDIR}/conf/site.conf