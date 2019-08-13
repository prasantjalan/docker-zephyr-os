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

# Clean up apt temp files
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Zephyr SDK
RUN wget -q https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.10.2/zephyr-sdk-0.10.2-setup.run
RUN chmod +x zephyr-sdk-0.10.2-setup.run
RUN mkdir -p /opt/zephyr-sdk/
RUN ./zephyr-sdk-0.10.2-setup.run -- -d /opt/zephyr-sdk

# Install GNU ARM Toolchain 
RUN wget -q --show-progress \
	https://developer.arm.com/-/media/Files/downloads/gnu-rm/7-2018q2/gcc-arm-none-eabi-7-2018-q2-update-linux.tar.bz2?revision=bc2c96c0-14b5-4bb4-9f18-bceb4050fee7?product=GNU%20Arm%20Embedded%20Toolchain,64-bit,,Linux,7-2018-q2-update \
	-O gcc-arm-none-eabi.tar.bz2
RUN echo "299ebd3f1c2c90930d28ab82e5d8d6c0 gcc-arm-none-eabi.tar.bz2" > gcc-arm-none-eabi.tar.bz2.md5
RUN md5sum -c gcc-arm-none-eabi.tar.bz2.md5
RUN mkdir -p /opt/gcc-arm/
RUN tar -xjpf gcc-arm-none-eabi.tar.bz2 --strip-components=1 -C /opt/gcc-arm/

# Set default Environemnt
#ENV ZEPHYR_TOOLCHAIN_VARIANT="zephyr"
#ENV ZEPHYR_SDK_INSTALL_DIR="/opt/zephyr-sdk"
ENV ZEPHYR_TOOLCHAIN_VARIANT="gnuarmemb"
ENV GNUARMEMB_TOOLCHAIN_PATH="/opt/gcc-arm"

RUN id build 2>/dev/null || useradd --uid 1000 --create-home build
RUN echo "build ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers
USER build
WORKDIR /home/build

CMD "/bin/bash"

