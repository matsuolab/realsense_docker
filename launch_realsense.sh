#!/bin/bash

IMAGE_NAME=ghcr.io/matsuolab/realsense_ros
CONTAINER_NAME=realsense_ros

TAG_NAME=latest
if [ "$(uname -m)" == "aarch64" ]; then
    TAG_NAME=jetson
fi

#ROS_MASTER_URI="http://`hostname -I | cut -d' ' -f1`:11311"
HSRB_HOSTNAME=hsrb.local
HSRB_IP=`avahi-resolve -4 --name ${HSRB_HOSTNAME} | cut -f 2`
ROS_MASTER_URI="http://${HSRB_IP}:11311"
ROS_IP=`hostname -I | cut -d' ' -f1`
#LAUNCH=rs_camera.launch
LAUNCH="rs_camera.launch camera:=hand_camera align_depth:=true respawn:=true depth_width:=640 depth_height:=480 color_width:=640 color_height:=480 depth_fps:=30 color_fps:=30"

#if [ ! $# -eq 0 ]; then
#    IP_CHECK=$(echo $1 | egrep "^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$")
#    if [ "${IP_CHECK}" ]; then
#        ROS_MASTER_URI="http://$1:11311"
#        if [ $# -ge 2 ]; then
#            LAUNCH=${@:2}
#        fi
#    else
#        LAUNCH=$@
#    fi
#fi

echo "IMAGE_NAME=${IMAGE_NAME}:${TAG_NAME}"
echo "CONTAINER_NAME=${CONTAINER_NAME}"
echo "ROS_MASTER_URI=${ROS_MASTER_URI}"
echo "ROS_IP=${ROS_IP}"
echo "LAUNCH=${LAUNCH}"

# docker stop ${CONTAINER_NAME}
# docker rm ${CONTAINER_NAME}

if [ ! "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
    if [ "$(docker ps -aq -f status=exited -f name=${CONTAINER_NAME})" ]; then
        # cleanup
        docker rm ${CONTAINER_NAME}
    fi
fi

docker run \
    --privileged \
    --volume="/dev:/dev" \
    --env ROS_MASTER_URI=${ROS_MASTER_URI} \
    --env ROS_IP=${ROS_IP} \
    --net="host" \
    --restart=always \
    --name ${CONTAINER_NAME} \
    ${IMAGE_NAME}:${TAG_NAME} \
    bash -c "roslaunch realsense2_camera ${LAUNCH}" &
