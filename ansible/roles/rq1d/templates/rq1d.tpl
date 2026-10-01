#!/bin/bash

MYDIR=`dirname $0` && [ ! `echo "$0" | grep '^\/'` ] && MYDIR=`pwd`/$MYDIR
DOCKER=`which docker`

DOCKIMG={{docker.rq1d}}
PORT={{docker.port}}
NAME=rq1d
DEV={{docker.dev}}
CORES={{docker.cores}}
MAXSESSION={{docker.maxsession}}

USRCONMGR=0
USERLIST=/opt/data/conf/userlist

HOSTIP=$(get-ip | tr -d "\n")

ENV="-e DEV=$DEV -e CORES=$CORES -e HOSTIP=$HOSTIP -e MAXSESSION=$MAXSESSION"

TMPDIR=/tmp

usage() {
    echo "usage: sh $0 help|start|stop|restart|ps|logs|pull|del"
    exit 1
}

[ $# -lt 1 ] && echo -n "Error: " && usage

CMD=$1

(cd $MYDIR

case "$CMD" in
   help)
          usage
          ;;
   restart)
          sh $0 stop
          sh $0 start
          ;;
   start)
          echo -n "Launch $NAME ($DOCKIMG image) (port $PORT) ..."
          $DOCKER run -d $ENV -p $PORT:3838 -v $TMPDIR:/tmp --name $NAME $DOCKIMG 2>&1 1>/dev/null
          if [ $? -eq 0 ]; then
            [ $USRCONMGR -eq 1 ] && $DOCKER cp $USERLIST $NAME:/run/userlist 2>&1 1>/dev/null
             echo " OK"
          else
             echo " Failed"
          fi
          ;;
   stop)
          echo -n "Stop $NAME ($DOCKIMG image) (port $PORT) ..."
          $DOCKER rm -f $NAME 2>&1 1>/dev/null
          if [ $? -eq 0 ]; then
             echo " OK"
          else
             echo " Failed"
          fi
          ;;
   ps)
          $DOCKER ps -a | grep -E "(NAMES|$NAME)"
          ;;
   logs)
          $DOCKER logs $NAME
          ;;
   pull)
          $DOCKER pull $DOCKIMG
          ;;
   del)
          $DOCKER rm -f $NAME
          rm -rf /tmp/Rtmp*
          ;;
   *) usage
      exit 2
esac

)
