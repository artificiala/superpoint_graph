FROM continuumio/miniconda

WORKDIR /project

ADD . /project/superpoint_graph


RUN  apt-get update \
  && apt-get install -y  wget gcc g++ make \
  && rm -rf /var/lib/apt/lists/* 

# SHELL ["/bin/bash", "-c"]

RUN wget https://cmake.org/files/v3.12/cmake-3.12.0.tar.gz \
  && tar -xvzf cmake-3.12.0.tar.gz \
  && cd cmake-3.12.0 \
  && ./bootstrap \
  && make \
  && make install


ENV PATH="opt/conda/include/python3.6m:/project/cmake-3.12.0/bin:opt/conda/bin:$PATH"
ENV CONDAENV="/opt/conda/envs/pytorch"
ENV PYTHONPATH="opt/conda/envs/pytorch/lib/python3.6m"

RUN conda update -y conda \
  && conda create --name pytorch python=3.6 \
  && /bin/bash -c "source activate pytorch" \
  && conda install -y pytorch=0.3.1 torchvision -c pytorch \
  && pip install git+https://github.com/pytorch/tnt.git@master \ 
  && pip install future python-igraph tqdm transforms3d pynvrtc fastrlock cupy h5py sklearn plyfile scipy \
  && conda install -y -c anaconda boost; conda install -y -c omnia eigen3; conda install -y eigen; conda install -y -c r libiconv \
  && cd /project/superpoint_graph/partition/ply_c \
  && cmake . -DPYTHON_LIBRARY=$CONDAENV/lib/libpython3.6m.so -DPYTHON_INCLUDE_DIR=$CONDAENV/include/python3.6m -DBOOST_INCLUDEDIR=$CONDAENV/include -DEIGEN3_INCLUDE_DIR=$CONDAENV/include/eigen3 \
  && make \
  && cd .. \
  && cd /project/superpoint_graph/partition \
  && git clone https://github.com/loicland/cut-pursuit \
  && cd cut-pursuit/src \
  && cmake . -DPYTHON_LIBRARY=$CONDAENV/lib/libpython3.6m.so -DPYTHON_INCLUDE_DIR=$CONDAENV/include/python3.6m -DBOOST_INCLUDEDIR=$CONDAENV/include -DEIGEN3_INCLUDE_DIR=$CONDAENV/include/eigen3 \
  && make

EXPOSE 80
