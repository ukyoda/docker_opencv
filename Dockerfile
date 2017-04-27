FROM centos:7.3.1611

MAINTAINER ukyoda

# 必要なパッケージインストール
################################################################################
RUN yum update -y \
        && yum install -y git gcc gcc-c++ autoconf automake cmake \
                          freetype-devel libtool make mercurial nasm \
                          pkgconfig zlib-devel \
                          bzip2-devel hostname \
                          openssl \
                          openssl-devel \
                          wget \
                          boost* \
        && yum clean all

# GlogとGflagsをインストール
################################################################################
RUN cd \
    && wget https://github.com/gflags/gflags/archive/v2.2.0.tar.gz \
    && tar xvzf v2.2.0.tar.gz \
    && cd gflags-2.2.0 \
    && cmake -DBUILD_SHARED_LIBS=true .  \
    && make \
    && make install \
    && cd \
    && rm -f v2.2.0.tar.gz

RUN cd \
    && wget https://github.com/google/glog/archive/v0.3.4.tar.gz \
    && tar xvzf v0.3.4.tar.gz \
    && cd glog-0.3.4 \
    && ./configure \
    && make \
    && make install \
    && cd \
    && rm -f v0.3.4.tar.gz


# Python 2.7準備
################################################################################
RUN cd \
    && yum install -y python-devel \
    && yum install -y epel-release \
    && yum install -y python-pip \
    && yum clean all
RUN pip install --upgrade pip \
    && pip install numpy

# OpenCVインストール
################################################################################
RUN cd \
    && wget https://github.com/opencv/opencv/archive/3.2.0.tar.gz -O opencv.tar.gz \
    && wget https://github.com/opencv/opencv_contrib/archive/3.2.0.tar.gz -O opencv-contrib.tar.gz \
    && mkdir opencv && tar xvzf opencv.tar.gz -C opencv --strip-components 1 \
    && mkdir opencv-contrib && tar xvzf opencv-contrib.tar.gz -C opencv-contrib --strip-components 1 \
    && cd opencv \
    && mkdir release \
    && cd release \
    && cmake -D CMAKE_BUILD_TYPE=RELEASE \
             -D CMAKE_INSTALL_PREFIX=/usr/local \
             -D BUILD_opencv_java=OFF \
             -D OPENCV_EXTRA_MODULES_PATH=/root/opencv-contrib/modules \
             -D WITH_CUDA=OFF \
             -D BUILD_TIFF=ON \
             -D BUILD_opencv_python2=ON \
             -D PYTHON_EXECUTABLE=$(which python) \
             .. \
    && make -j$(nproc) \
    && make install \
    && cd \
    && rm -f opencv.tar.gz \
    && rm -f opencv-contrib.tar.gz

# PKG_CONFIG_PATH設定
ENV PKG_CONFIG_PATH ${PKG_CONFIG_PATH}:/usr/local/lib/pkgconfig/
# Boostのパス設定
ENV BOOST_ROOT /usr/lib64/
ENV Boost_INCLUDE_DIR /usr/include/boost/
# LD_LIBRARY_PATH設定
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/lib

# WORK_DIRECTORY設定
WORKDIR /app

# CMD設定(BASH)
CMD ["/bin/bash"]
