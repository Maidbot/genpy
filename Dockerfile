FROM ubuntu:18.04

ENV ROBOT_WS="/home/robot" \
    LC_ALL=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    ROS_DISTRO=melodic \
    ROS_PYTHON_VERSION=2 

WORKDIR $ROBOT_WS

RUN apt-get update && \
    apt-get -y -qq -o Dpkg::Use-Pty=0 install --no-install-recommends --fix-missing curl gnupg && \
    apt-get clean

# Install minimal dependencies
RUN echo "deb http://packages.ros.org/ros/ubuntu bionic main" > /etc/apt/sources.list.d/ros-latest.list && \
    apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654 && \
    apt-get update && \
    apt-get -y -qq -o Dpkg::Use-Pty=0 install --no-install-recommends --fix-missing \
      ros-${ROS_DISTRO}-genmsg python-rospkg python-catkin-pkg python-catkin-pkg-modules python-setuptools

RUN apt-get install -y -qq -o Dpkg::Use-Pty=0 --no-install-recommends --fix-missing build-essential python-pip
RUN pip install --no-cache-dir --upgrade pip && \ 
    pip install --no-cache-dir -U \
      catkin_tools \
      wstool

# Use /bin/bash
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Setup ros workspace 
RUN source /opt/ros/${ROS_DISTRO}/setup.bash && \
    mkdir -p catkin_ws/src/genpy && \
    cd catkin_ws && \
    catkin config --init --install --cmake-args \
      -DCATKIN_ENABLE_TESTING==${CMAKE_ENABLE_TESTING} \
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} && \
    catkin config --extend /opt/ros/${ROS_DISTRO}

# Build flags
ENV CMAKE_ENABLE_TESTING=1 \
    CMAKE_BUILD_TYPE=RelwithDebInfo

# Build genpy from source and run tests (unit serde test works here....)
COPY . catkin_ws/src/genpy 
RUN rm -rf catkin_ws/src/genpy/test_pkg && cd catkin_ws && \
  catkin build genpy --catkin-make-args run_tests && \
  catkin clean -y

# Cleanup src build + test and install all of roscore (test debs)
RUN rm -rf catkin_ws/src/genpy && \
    apt-get update && \ 
    apt-get -y -qq -o Dpkg::Use-Pty=0 install --no-install-recommends --fix-missing ros-${ROS_DISTRO}-ros-core

# Build flags
ENV CMAKE_ENABLE_TESTING=0 \
    CMAKE_BUILD_TYPE=Release

# Build the test package's msg
COPY test_pkg catkin_ws/src/test_pkg
RUN cd catkin_ws && catkin build test_pkg