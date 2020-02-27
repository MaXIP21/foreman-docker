FROM ubuntu:18.04
# install packages

MAINTAINER Peter Bacsai ""

RUN apt-get update && apt-get install -y openssh-server git nmap
RUN mkdir /var/run/sshd
RUN echo 'root:password' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN mkdir /root/.ssh/

# Copy over private key, and set permissions
# Warning! Anyone who gets their hands on this image will be able
# to retrieve this private key file from the corresponding image layer
ADD id_rsa /root/.ssh/id_rsa

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN useradd -ms /bin/bash r0ck

USER r0ck
WORKDIR /home/r0ck

RUN /usr/bin/ssh-keygen -A

# Cloning foreman installer 
RUN git clone --recursive git://github.com/theforeman/foreman-installer.git -b develop

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
