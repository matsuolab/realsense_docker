ARG ros_distro=melodic
FROM ros:${ros_distro}-ros-base

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

ARG ros_distro
ENV ROS_DISTRO=${ros_distro}
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ros-${ROS_DISTRO}-realsense2-camera \
        ros-${ROS_DISTRO}-rgbd-launch \
        ros-${ROS_DISTRO}-image-transport* && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#RUN mkdir -p /root/catkin_ws/src && \
#    cd /root/catkin_ws/src && \
#    rosdep init

#RUN cd /root/catkin_ws/src && \
#    source /opt/ros/melodic/setup.bash && \
#    git clone -b indigo-devel https://github.com/ros-perception/image_transport_plugins && \
#    cd /root/catkin_ws && \
#    rosdep update && \
#    rosdep install -from-paths . --ignore-src --rosdistro melodic -y && \
#    catkin_make

RUN echo 'source /opt/ros/${ROS_DISTRO}/setup.bash && exec "$@"' \
    > /root/ros_entrypoint.sh

ENTRYPOINT ["bash", "/root/ros_entrypoint.sh"]
