# syntax=docker/dockerfile:1
# GPU accelerated using CUDA
# the -devel base image may not require the g++ installation but that is 3GB larger
FROM pytorch/pytorch:2.0.1-cuda11.7-cudnn8-runtime
RUN apt-get update && apt-get install -y software-properties-common && add-apt-repository -y ppa:ubuntu-toolchain-r/test
RUN apt-get install -y g++-11 make
COPY ./requirements.txt .
ENV CC=gcc-11
ENV CXX=g++-11
RUN --mount=type=cache,target=/root/.cache pip install -r requirements.txt
COPY SOURCE_DOCUMENTS ./SOURCE_DOCUMENTS
COPY ingest.py constants.py ./
# Docker BuildKit does not support GPU during *docker build* time right now, only during *docker run*.
# if this changes in the future you can `docker build --build-arg device_type=cuda  . -t localgpt`
ARG device_type=cpu
RUN --mount=type=cache,target=/root/.cache python ingest.py --device_type $device_type
COPY . .
ENV device_type=cuda
CMD python run_localGPT.py device_type=$device_type
# build as `docker build . -t localgpt`
# requires Nvidia container toolkit
# run as `docker run -it --mount src="$HOME/.cache",target=/root/.cache,type=bind --gpus=all localgpt`
