# Image Toolbox

This repository contains source code for an OCI image that contains tools used
when building, scanning, signing, and pushing images to OCI repositories.

## Application image delivery pipeline

The tasks in an application image delivery pipeline may include:

1. Build the image
2. Scan the image for vulnerabilities
3. Sign the image as builder
4. Generate a SBOM for the image
5. Push image, signing artifact, and SBOM to its OCI repository

It is assumed that building, testing, and scanning application source code
tasks were performed successfully in an earlier pipeline step.

Additional artifacts, such as Helm charts, may also be stored in the ECR
repository, but are not part of an image delivery pipeline, and may be
performed in a later pipeline step if image delivery is successful.

## Tools

The tools in this image build upon the official Atlassian Bitbucket Pipelines
image, and additionally include tools used in an image delivery pipeline step:

- [grype](https://github.com/anchore/grype) for scanning images for vulnerabilities
- [syft](https://github.com/anchore/syft) for generating SBOMs
- [cosign](https://github.com/sigstore/cosign) for signing images
- [trivy](https://github.com/aquasecurity/trivy) for scanning images for vulnerabilities
- [trufflehog](https://github.com/trufflesecurity/trufflehog) for scanning images for secrets
- [imagecheck](https://github.com/sambatv/imagecheck) orchestrates the above tools and
  delivers scan reports and summaries to S3 for later analysis, auditing, and reporting

## Usage

The image is intended to be used in a Bitbucket Pipeline step.

```yaml
pipelines:
  default:
  - step:
      name: Build, scan, sign, and push images to ECR
      image:
        name: ghcr.io/image-toolbox:latest
      script:
      - echo "Building, scanning, signing, and pushing images..."
      # The toolchain available in /usr/local/bin in your PATH
```

Typically, it is not good advice to depend on the `latest` tag, as it is mutable.
However, in our case, it is precisely what we want to use as a user of the image.

## Publishing

This image extends the `atlassian/default-image:latest` image and adds latest
versions of the tools listed above

It is built and delivered to ECR on a daily cadence for use as the image in
Bitbucket pipeline steps.

The image tag is the datestamp of the build, in the format `YYYY-MM-DD`.
Datestamp tags are immutable.

The image is also tagged with the `latest` tag  This `latest` tag is mutable.

Both tags are pushed to their ECR repositories upon successful daily builds.
