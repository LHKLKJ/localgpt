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
COPY . .
# GPU not accessible in Docker build step
RUN --mount=type=cache,target=/root/.cache python ingest.py --device_type cpu
CMD ["python", "run_localGPT.py"]
# requires Nvidia container toolkit
# run as `docker run -it --mount src="$HOME/.cache",target=/root/.cache,type=bind --gpus=all localgpt`
