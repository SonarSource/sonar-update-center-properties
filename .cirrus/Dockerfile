ARG CIRRUS_AWS_ACCOUNT
FROM ${CIRRUS_AWS_ACCOUNT}.dkr.ecr.eu-central-1.amazonaws.com/base:j21-m3.9-latest

USER root

# AWS CLI
RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.7.7.zip -o awscliv2.zip && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip

USER sonarsource
