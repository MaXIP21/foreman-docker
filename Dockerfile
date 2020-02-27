FROM ubuntu:18.04
# install packages

MAINTAINER Peter Bacsai ""

# Take an SSH key as a build argument.
ARG SSH_KEY

RUN apt-get update && apt-get install -y openssh-server git nmap sudo 
RUN mkdir /var/run/sshd
RUN echo 'root:password' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

RUN mkdir -p /root/.ssh/ && \
    echo "$SSH_KEY" > /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/"$SSH_KEY"

# ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN useradd -ms /bin/bash r0ck

USER r0ck
WORKDIR /home/r0ck

# Cloning foreman installer 
# RUN git clone --recursive git://github.com/theforeman/foreman-installer.git -b develop

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
