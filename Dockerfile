FROM crashvb/base:20.04-202201080422@sha256:57745c66439ee82fda88c422b4753a736c1f59d64d2eaf908e9a4ea1999225ab as builder
ARG python_version=3.8.3
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


FROM crashvb/base:20.04-202201080422@sha256:57745c66439ee82fda88c422b4753a736c1f59d64d2eaf908e9a4ea1999225ab
ARG org_opencontainers_image_created=undefined
ARG org_opencontainers_image_revision=undefined
ARG python_version=3.8.3
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
RUN docker-apt git-core openssh-client sshpass && \
	pyenv global ${python_version} && \
	python -m pip install --no-cache-dir --upgrade pip wheel && \
	python -m pip install --no-cache-dir ansible

# Configure: ansible
COPY ansible* /usr/local/bin/
RUN useradd --create-home ansible && \
	mkdir --parents /home/ansible/.ssh && \
	install --directory --group=root --mode=0755 --owner=root /etc/ansible/hosts && \
	printf "[localhost]\nlocalhost\n" > /etc/ansible/hosts/hosts.localhost

# Configure: entrypoint
COPY entrypoint.ansible /etc/entrypoint.d/ansible
