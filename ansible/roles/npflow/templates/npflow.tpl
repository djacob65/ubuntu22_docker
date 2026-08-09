#!/bin/sh
MYDIR=/opt/npflow
PORT={{docker.port}}
IMAGE={{docker.npflow}}
CONTAINER=npflow
CONF=$MYDIR/etc/npflow.conf
DEFDATADIR=/opt/data
DATADIR=$(cat $CONF | grep DATASETS | cut -d'=' -f2 | tr -d "\n")
DATADIR=${DATADIR:-$DEFDATADIR}
VOL_TMP="-v $DATADIR/tmp/np:/tmp -v $DATADIR/tmp/nv:/var/www/html/nv/tmp"

mkdir -p $DATADIR/tmp/np
mkdir -p $DATADIR/tmp/nv
chmod -R 777 $DATADIR/tmp

CMD=$1
VOLS="-v $DATADIR:/opt/data"

usage() { echo "usage: sh \$0 start|stop|ps|restart|logs|update";  exit 1; }
case "$CMD" in
   start)
        docker run -d --env-file $CONF $VOLS $VOL_TMP -p $PORT:80 --name $CONTAINER $IMAGE
        docker logs $CONTAINER
        ;;
   stop)
        docker rm -f $CONTAINER
        ;;
   restart)
        ( sh $0 stop; sh $0 start)
        ;;
   logs)
        docker logs $CONTAINER
        ;;
   ps)
        docker ps | head -1
        docker ps | grep "nmrprocflow/"
        ;;
   images)
        echo $(docker inspect $CONTAINER | grep Image | cut -d":" -f2 | tr -d "\n" | tr -d "," )
        ;;
   update)
        docker pull $IMAGE
        ;;
   *) usage
      exit 2
esac
