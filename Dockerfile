FROM crashvb/base:20.04-202201080422@sha256:57745c66439ee82fda88c422b4753a736c1f59d64d2eaf908e9a4ea1999225ab
ARG org_opencontainers_image_created=undefined
ARG org_opencontainers_image_revision=undefined
LABEL \
	org.opencontainers.image.authors="Richard Davis <crashvb@gmail.com>" \
	org.opencontainers.image.base.digest="sha256:57745c66439ee82fda88c422b4753a736c1f59d64d2eaf908e9a4ea1999225ab" \
	org.opencontainers.image.base.name="crashvb/base:20.04-202201080422" \
	org.opencontainers.image.created="${org_opencontainers_image_created}" \
	org.opencontainers.image.description="Image containing ansible." \
	org.opencontainers.image.licenses="Apache-2.0" \
	org.opencontainers.image.source="https://github.com/crashvb/ansible-docker" \
	org.opencontainers.image.revision="${org_opencontainers_image_revision}" \
	org.opencontainers.image.title="crashvb/ansible" \
	org.opencontainers.image.url="https://github.com/crashvb/ansible-docker"

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
