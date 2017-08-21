FROM centos:7

# Install Essentials
RUN yum update -y && \
         yum clean all

# Install Packages
RUN yum install -y git && \
         yum install -y wget && \
         yum install -y openssh-server && \
         yum install -y java-1.8.0-openjdk && \
         yum install -y sudo && \
	 yum install -y svn && \
         yum clean all

# gen dummy keys, centos doesn't autogen them like ubuntu does
RUN /usr/bin/ssh-keygen -A

# Set SSH Configuration to allow remote logins without /proc write access
RUN sed -ri 's/^session\s+required\s+pam_loginuid.so$/session optional pam_loginuid.so/' /etc/pam.d/sshd

# Create Jenkins User
RUN useradd cmsops -u 440 -m -s /bin/bash

# Add public key for Jenkins login
RUN mkdir /home/cmsops/.ssh
#COPY /files/authorized_keys /root/.ssh/authorized_keys
COPY /files/authorized_keys /home/cmsops/.ssh/authorized_keys
RUN chown -R cmsops /home/cmsops
RUN chgrp -R cmsops /home/cmsops
#RUN chmod 600 /root/.ssh/authorized_keys
#RUN chmod 700 /root/.ssh
RUN chmod 600 /home/cmsops/.ssh/authorized_keys
RUN chmod 700 /home/cmsops/.ssh

# Add the jenkins user to sudoers
RUN echo "cmsops  ALL=(ALL)  ALL" >> etc/sudoers

# Set Name Servers
COPY /files/resolv.conf /etc/resolv.conf

#USER cmsops
#USER root

# Expose SSH port and run SSHD
EXPOSE 22
CMD ["/usr/sbin/sshd","-D"]
