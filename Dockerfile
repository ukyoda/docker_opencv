FROM centos:6.8

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
                          boost boost-dev \
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

# Python 2.7インストール
################################################################################
RUN cd \
    && wget https://www.python.org/ftp/python/2.7.8/Python-2.7.8.tgz \
    && tar xvzf Python-2.7.8.tgz \
    && cd Python-2.7.8 \
    && ./configure --prefix=/usr/local \
    && make \
    && make altinstall \
    && cd \
    && rm -f Python-2.7.8.tgz
RUN cd \
    && wget --no-check-certificate https://pypi.python.org/packages/source/s/setuptools/setuptools-1.4.2.tar.gz \
    && tar -xvf setuptools-1.4.2.tar.gz \
    && cd setuptools-1.4.2 \
    && python2.7 setup.py install \
    && curl https://bootstrap.pypa.io/get-pip.py | python2.7 - \
    && cd \
    && rm -f setuptools-1.4.2.tar.gz

RUN pip install numpy

#
# # OpenCVインストール
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
             -D PYTHON_EXECUTABLE=$(which python2.7) \
             .. \
    && make -j$(nproc) \
    && make install \
    && cd \
    && rm opencv.tar.gz \
    && rm opencv-contrib.tar.gz

# PKG_CONFIG_PATH設定
ENV PKG_CONFIG_PATH ${PKG_CONFIG_PATH}:/usr/local/lib/pkgconfig/

# WORK_DIRECTORY設定
WORKDIR /app

# CMD設定(BASH)
CMD /bin/bash
