# Image Toolbox

This repository contains source code for an OCI image that contains tools
useful for building, scanning, signing, and publishing OCI images.

## Application image delivery pipeline

The tasks in an application image delivery pipeline may include:

1. Build the image
2. Scan the image for vulnerabilities
3. Sign the image as builder
4. Generate a SBOM for the image
5. Push image, signing artifact, and SBOM to its OCI repository

It is assumed that building, testing, and scanning application source code
tasks were performed successfully in an earlier pipeline step.

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

## Publishing

This image extends the `atlassian/default-image:latest` image and adds latest
versions of the tools listed above

It is built and published to [ghcr.io/sambatv/image-toolbox](https://ghcr.io/sambatv/image-toolbox)
on a daily cadence for use as a build pipeline step image, as defined in its
[imagepublisher.yaml](.github/workflows/imagepublisher.yaml) Github Actions
workflow, using a datestamp tag, in the format `YYYY-MM-DD`.

## Usage

An example of its use in a Bitbucket Pipeline step:

```yaml
pipelines:
  default:
  - step:
      name: Build, scan, sign, and publish images
      image:
        name: ghcr.io/image-toolbox:latest
        username: $GHCR_USERNAME
        password: $GHCR_TOKEN
      script:
      - echo "Building, scanning, signing, and publishing images..."
      # The toolchain available in /usr/local/bin in your PATH
```

Typically, it is not good advice to depend on the `latest` tag, as it is mutable.
However, in our case, it is precisely what we want to use as a user of the image.

Also note that $GHCR_USERNAME and $GHCR_TOKEN here are defined in Bitbucket
workspace variables, and are used to authenticate to the GitHub Container
Registry (GHCR), with the $GHCR_TOKEN being a personal access token. 
