FROM crashvb/base:24.04-202508010159@sha256:f7b3a015c749980c2427241686134908e4f82e2c0b72688dac37cb59e4e05169 AS builder
ARG python_version=3.12.3
RUN docker-apt \
	build-essential \
	curl \
	git-core \
	libbz2-dev \
	libffi-dev \
	liblzma-dev \
	libncursesw5-dev \
	libreadline-dev \
	libsqlite3-dev \
	libssl-dev \
	libxml2-dev \
	libxmlsec1-dev \
	llvm \
	make \
	tk-dev \
	wget \
	xz-utils \
	zlib1g-dev && \
	git clone https://github.com/pyenv/pyenv.git "/opt/pyenv"
RUN PYENV_ROOT="/opt/pyenv" PATH="/opt/pyenv/bin:/opt/pyenv/shims:${PATH}" pyenv install ${python_version}


FROM crashvb/base:24.04-202508010159@sha256:f7b3a015c749980c2427241686134908e4f82e2c0b72688dac37cb59e4e05169
ARG org_opencontainers_image_created=undefined
ARG org_opencontainers_image_revision=undefined
ARG python_version=3.12.3
LABEL \
	org.opencontainers.image.authors="Richard Davis <crashvb@gmail.com>" \
	org.opencontainers.image.base.digest="sha256:f7b3a015c749980c2427241686134908e4f82e2c0b72688dac37cb59e4e05169" \
	org.opencontainers.image.base.name="crashvb/base:24.04-202508010159" \
	org.opencontainers.image.created="${org_opencontainers_image_created}" \
	org.opencontainers.image.description="Image containing ansible." \
	org.opencontainers.image.licenses="Apache-2.0" \
	org.opencontainers.image.source="https://github.com/crashvb/ansible-docker" \
	org.opencontainers.image.revision="${org_opencontainers_image_revision}" \
	org.opencontainers.image.title="crashvb/ansible" \
	org.opencontainers.image.url="https://github.com/crashvb/ansible-docker"

# Install packages, download files ...
ENV \
	LANG=C.UTF-8 \
	LC_ALL=C.UTF-8 \
	PYENV_ROOT="/opt/pyenv" \
	PATH="/opt/pyenv/versions/${python_version}/bin:/opt/pyenv/bin:/opt/pyenv/shims:${PATH}"
COPY --from=builder /opt/pyenv /opt/pyenv
RUN echo "#!/bin/bash" >> /etc/profile.d/pyenv.sh && \
	echo "export PYENV_ROOT=\"/opt/pyenv\"" >> /etc/profile.d/pyenv.sh && \
	echo "export PATH=\"\${PYENV_ROOT}/versions/${python_version}/bin:\${PYENV_ROOT}/bin:\${PYENV_ROOT}/shims:\${PATH}\"" >> /etc/profile.d/pyenv.sh
# hadolint ignore=DL3013
RUN docker-apt git-core jq openssh-client sshpass && \
	pyenv global ${python_version} && \
	python -m pip install --no-cache-dir --upgrade pip wheel && \
	python -m pip install --no-cache-dir ansible yq

# Configure: ansible
ENV \
	ANISBLE_BECOME_FLAGS="--preserve-env=SSH_AUTH_SOCK" \
	ANISBLE_ROLES_PATH=/etc/ansible/roles \
	ANSIBLE_SSH_COMMON_ARGS="-o ControlPersist=no -o ForwardAgent=yes"
COPY ansible* /usr/local/bin/
RUN useradd --create-home ansible --shell=/bin/bash && \
	install --group=ansible --mode=0644 --owner=ansible /dev/null /home/ansible/.bashrc && \
	sed --expression='s/31m/34m/g' /root/.bashrc > /home/ansible/.bashrc && \
	echo "source /etc/profile.d/pyenv.sh" >> /home/ansible/.bashrc && \
	install --directory --group=ansible --mode=0755 --owner=ansible /home/ansible/.ssh && \
	install --directory --group=root --mode=0755 --owner=root /etc/ansible/hosts /etc/ansible/roles && \
	printf "[localhost]\nlocalhost\n" > /etc/ansible/hosts/hosts.localhost

# Configure: entrypoint
COPY entrypoint.ansible /etc/entrypoint.d/ansible
