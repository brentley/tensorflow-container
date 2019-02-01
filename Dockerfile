# Copyright 2018 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============================================================================

# adapted from https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tools/dockerfiles/dockerfiles/gpu.Dockerfile

ARG UBUNTU_VERSION=16.04

FROM nvidia/cuda:9.0-base-ubuntu${UBUNTU_VERSION} as base

# For CUDA profiling, TensorFlow requires CUPTI.
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH

ARG PYTHON=python3

ENV TF_NEED_CUDA 1
ENV TF_NEED_TENSORRT 1
ENV TF_CUDA_COMPUTE_CAPABILITIES=3.5,5.2,6.0,6.1,7.0
ENV TF_CUDA_VERSION=9.0
ENV TF_CUDNN_VERSION=7

# NCCL 2.x
ENV TF_NCCL_VERSION=2

# See http://bugs.python.org/issue19846
ENV LANG C.UTF-8

COPY bashrc /etc/bash.bashrc

# Pick up some TF dependencies
RUN chmod a+rx /etc/bash.bashrc \
        && apt-get update && apt-get install -y --no-install-recommends \
        git \
        time \
        build-essential \
        cuda-command-line-tools-9-0 \
        cuda-cublas-9-0 \
        cuda-cufft-9-0 \
        cuda-curand-9-0 \
        cuda-cusolver-9-0 \
        cuda-cusparse-9-0 \
        curl \
        libcudnn7=7.2.1.38-1+cuda9.0 \
        libnccl2=2.2.13-1+cuda9.0 \
        libfreetype6-dev \
        libhdf5-serial-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
        rsync \
        software-properties-common \
        unzip \
        && apt-get update \
        && apt-get install nvinfer-runtime-trt-repo-ubuntu1604-4.0.1-ga-cuda9.0 \
        && apt-get update \
        && apt-get install libnvinfer4=4.1.2-1+cuda9.0 \
        && apt-get update && apt-get install -y \
            ${PYTHON} \
            ${PYTHON}-pip \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/* \
        && ln -s $(which ${PYTHON}) /usr/local/bin/python # Copyright 2018 The TensorFlow Authors. All Rights Reserved.
        
RUN git clone https://github.com/tensorflow/benchmarks.git \
        && cd /benchmarks/ \
        && git checkout cnn_tf_v1.9_compatible

WORKDIR /benchmarks/scripts/tf_cnn_benchmarks/
CMD time python tf_cnn_benchmarks.py --batch_size=32 --model=resnet50 --variable_update=parameter_server --data_format=NHWC --device=cpu --summary_verbosity=1

FROM base AS tensorflow-cpu
ARG PIP=pip3

# Options:
#   tensorflow
#   tensorflow-gpu
#   tf-nightly
#   tf-nightly-gpu
ARG TF_PACKAGE=tensorflow
RUN     ${PIP} install --no-cache-dir ${TF_PACKAGE}

FROM base AS tensorflow-gpu
ARG PIP=pip3

ENV GPU=1
ENV BATCH_SIZE=32

# Options:
#   tensorflow
#   tensorflow-gpu
#   tf-nightly
#   tf-nightly-gpu
ARG TF_PACKAGE=tensorflow-gpu
RUN     ${PIP} install --no-cache-dir ${TF_PACKAGE}

WORKDIR /benchmarks/scripts/tf_cnn_benchmarks/
CMD time python tf_cnn_benchmarks.py --num_gpus=$GPU --batch_size=$BATCH_SIZE --model=resnet50 --variable_update=parameter_server --data_format=NHWC --device=gpu --summary_verbosity=1