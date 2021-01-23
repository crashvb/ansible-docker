FROM crashvb/base:20.04-202007030444
LABEL maintainer="Richard Davis <crashvb@gmail.com>"

# Install packages, download files ...
RUN docker-apt ansible git-core openssh-client sshpass

# Configure: ansible
ADD ansible* /usr/local/bin/
RUN useradd --create-home ansible && \
	mkdir --parents /home/ansible/.ssh && \
	mv /etc/ansible/hosts /etc/ansible/hosts.dist && \
	install --directory --group=root --mode=0755 --owner=root /etc/ansible/hosts && \
	mv /etc/ansible/hosts.dist /etc/ansible/hosts/ && \
	echo "[localhost]\nlocalhost" > /etc/ansible/hosts/hosts.localhost

# Configure: entrypoint
ADD entrypoint.ansible /etc/entrypoint.d/ansible
