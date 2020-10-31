FROM nvidia/cuda:10.2-devel-ubuntu18.04

# 中文问题
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# 东八区问题
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# apt修改阿里源
RUN sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list \
    && sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

# 由于 https://github.com/NVIDIA/nvidia-docker/issues/969 的问题
## 临时将 nvidia 的仓库另存为到其他地方，以保障 ci 流畅
RUN mkdir -p /opt/sources.list.d/  \
    && mv /etc/apt/sources.list.d/* /opt/sources.list.d/

# 安装Anaconda
ENV PATH /opt/conda/bin:$PATH
RUN apt-get update \
  && apt-get install -y wget \
#  && wget -c https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh -O ~/anaconda.sh \
  && wget -O ~/anaconda.sh -c https://ops-software-binary-1255440668.cos.ap-chengdu.myqcloud.com/anaconda/Anaconda3-2020.02-Linux-x86_64.sh \
  && /bin/bash ~/anaconda.sh -b -p /opt/conda \
  && rm ~/anaconda.sh \
  && ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh \
  && echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc \
  && echo "conda activate base" >> ~/.bashrc  \
  && rm -rf /var/lib/apt/lists/*

# conda更改清华源
RUN conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/ \
  && conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/msys2/ \
  && conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda/ \
  && conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/menpo/ \
  && conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/ \
  && conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/ \
  && conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch/ \
  && conda config --set show_channel_urls yes

# conda安装依赖库
RUN conda install -y cudatoolkit=10.2  && conda clean -a

# apt安装依赖库
RUN apt update \
  && apt-get install -y git g++ \
  && rm -rf /var/lib/apt/lists/*

# pip设置修改
# add pip aliyun source
COPY pip/pip.conf /root/.pip/pip.conf
