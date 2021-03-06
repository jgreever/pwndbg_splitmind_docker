# This dockerfile was created for development & testing purposes
#
# Build as:             docker build -t pwndbg .
#
# For testing use:      docker run --rm -it --cap-add=SYS_PTRACE pwndbg bash
#
# For development, mount the directory so the host changes are reflected into container:
#    
#       docker run -it --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -v `pwd`:/pwndbg pwndbg bash
#
FROM ubuntu:20.04
WORKDIR /pwndbg
ENV TERM screen-256color
RUN apt-get update
RUN apt-get install -y apt-utils locales locales-all tmux
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt-get install -y vim
COPY ./setup.sh /pwndbg/
COPY ./requirements.txt /pwndbg/
RUN sed -i "s/^git submodule/#git submodule/" ./setup.sh && \
    DEBIAN_FRONTEND=noninteractive ./setup.sh
ADD ./setup-test-tools.sh /pwndbg/
RUN ./setup-test-tools.sh
RUN mv /root/.gdbinit /root/.gdbinit.original && \
    cd / && \
    git clone https://github.com/jerdna-regeiz/splitmind && \
    echo "PYTHON_MINOR=$(python3 -c "import sys;print(sys.version_info.minor)")" >> /root/.bashrc && \
    echo "PYTHON_PATH=\"/usr/local/lib/python3.${PYTHON_MINOR}/dist-packages/bin\"" >> /root/.bashrc && \
    echo "export PATH=$PATH:$PYTHON_PATH" >> /root/.bashrc
COPY . /pwndbg/
RUN cp /pwndbg/gdbinit /root/.gdbinit
RUN git submodule update --init --recursive
RUN chsh -s /usr/bin/tmux root
