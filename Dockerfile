FROM tensorflow/tensorflow:latest-py3

COPY opencv.zip /
COPY opencv_contrib.zip /
COPY ippicv_linux_20151201.tgz /
COPY protobuf-cpp-3.1.0.tar.gz /
COPY dlib-19.7.tar.gz /
COPY sources.list /

RUN cp /sources.list /etc/apt/sources.list
RUN apt-get -y update
RUN apt-get -y upgrade

RUN apt-get update -y --fix-missing
RUN apt-get install -y ffmpeg
RUN apt-get install -y build-essential cmake pkg-config \
                    libjpeg8-dev libtiff5-dev libjasper-dev libpng12-dev \
                    libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
                    libxvidcore-dev libx264-dev \
                    libgtk-3-dev \
                    libatlas-base-dev gfortran \
                    libboost-all-dev \
                    python3 python3-dev python3-numpy

RUN apt-get install -y wget vim python3-tk python3-pip

WORKDIR /
RUN unzip opencv.zip
RUN unzip opencv_contrib.zip
RUN mkdir /opencv-3.2.0/3rdparty/ippicv/downloads \
    && mkdir /opencv-3.2.0/3rdparty/ippicv/downloads/linux-808b791a6eac9ed78d32a7666804320e \
    && cp /ippicv_linux_20151201.tgz /opencv-3.2.0/3rdparty/ippicv/downloads/linux-808b791a6eac9ed78d32a7666804320e/
RUN mkdir /opencv_contrib-3.2.0/modules/dnn/.download \
    && mkdir /opencv_contrib-3.2.0/modules/dnn/.download/bd5e3eed635a8d32e2b99658633815ef \
    && mkdir /opencv_contrib-3.2.0/modules/dnn/.download/bd5e3eed635a8d32e2b99658633815ef/v3.1.0 \
    && cp /protobuf-cpp-3.1.0.tar.gz /opencv_contrib-3.2.0/modules/dnn/.download/bd5e3eed635a8d32e2b99658633815ef/v3.1.0/

# install opencv3.2
RUN cd /opencv-3.2.0/ \
   && mkdir build \
   && cd build \
   && cmake -D CMAKE_BUILD_TYPE=RELEASE \
            -D INSTALL_C_EXAMPLES=OFF \
            -D INSTALL_PYTHON_EXAMPLES=ON \
            -D OPENCV_EXTRA_MODULES_PATH=/opencv_contrib-3.2.0/modules \
            -D BUILD_EXAMPLES=OFF \
            -D BUILD_opencv_python2=OFF \
            -D BUILD_NEW_PYTHON_SUPPORT=ON \
            -D CMAKE_INSTALL_PREFIX=$(python3 -c "import sys; print(sys.prefix)") \
            -D PYTHON_EXECUTABLE=$(which python3) \
            -D WITH_FFMPEG=1 \
            -D WITH_CUDA=0 \
            .. \
    && make -j8 \
    && make install \
    && ldconfig \
    && rm /opencv.zip \
    && rm /opencv_contrib.zip

# Install dlib 19.7
WORKDIR /
RUN tar -zxvf dlib-19.7.tar.gz

RUN cd dlib-19.7 \
    && mkdir build \
    && cd build \
    && cmake .. \
    && cmake --build . --config Release \
    && cd /dlib-19.7 \
    && pip3 install setuptools \
    && python3 setup.py install \
    && cd $WORKDIR \
    && rm /dlib-19.7.tar.gz

CMD ["/bin/bash"]
