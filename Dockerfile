FROM ubuntu:18.04

LABEL maintainer="Prasant Jalan <prasant.jalan@gmail.com>"

RUN apt-get update

# Avoid user interaction when installting tzdata package
ENV TZ="Asia/Kolkata"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install locales
RUN apt -y install locales && \
	dpkg-reconfigure locales && \
	locale-gen en_US.UTF-8 && \
	update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# Install packages required by zephyr
RUN apt-get install --quiet -y --no-install-recommends git cmake gperf \
	ccache dfu-util device-tree-compiler wget \
	python3-pip python3-setuptools python3-tk python3-wheel xz-utils file \
	make gcc gcc-multilib 

# Upgrade pip
RUN pip3 install -U pip

# Install west package required for zephyr git repo management
RUN pip3 install west

# Install Additional requirements from zephyr repo
ENV LC_CTYPE=en_US.UTF-8
ENV LANG=en_US.UTF-8
RUN wget https://github.com/zephyrproject-rtos/zephyr/blob/master/scripts/requirements.txt
#RUN pip3 install --no-cache-dir -r requirements.txt
RUN pip3 install --no-cache-dir \
	wheel==0.30.0 \
	breathe==4.9.1 \
	sphinx==1.7.5 \
	docutils==0.14 \
	sphinx_rtd_theme \
	sphinxcontrib-svg2pdfconverter \
	junit2html \
	PyYAML>=3.13 \
	ply==3.10 \
	gitlint \
	pyelftools==0.24 \
	pyocd==0.21.0 \
	pyserial \
	pykwalify \
	colorama \
	Pillow \
	intelhex \
	pytest \
	gcovr


# Install additional utility packages
RUN apt-get install -y curl dosfstools tree vim

RUN id build 2>/dev/null || useradd --uid 1000 --create-home build
RUN echo "build ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers

# Clean up apt temp files
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER build
WORKDIR /home/build

# Install Zephyr SDK
RUN wget -q https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.10.2/zephyr-sdk-0.10.2-setup.run
RUN chmod +x zephyr-sdk-0.10.2-setup.run
RUN ./zephyr-sdk-0.10.2-setup.run -- -d /home/build/zephyr-sdk-0.10.2
ENV ZEPHYR_TOOLCHAIN_VARIANT="zephyr"
ENV ZEPHYR_SDK_INSTALL_DIR="/home/build/zephyr-sdk-0.10.2"

CMD "/bin/bash"

