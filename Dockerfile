FROM atlassian/default-image:latest
ADD "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" "awscliv2.zip"
ADD "https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64" "/usr/local/bin/cosign"
RUN apt-get update && apt-get install -y && rm -rf /var/lib/apt/lists/* \
    && curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin \
    && curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin \
    && curl -sSfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin \
    && curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b /usr/local/bin \
    && curl -sSfL https://raw.githubusercontent.com/sambatv/imagecheck/main/install.sh | sh -s -- -b /usr/local/bin \
    && unzip awscliv2.zip && ./aws/install && rm -rf aws/ awscliv2.zip \
    && chmod +x /usr/local/bin/cosign
