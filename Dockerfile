# # Find eligible builder and runner images on Docker Hub. We use Ubuntu/Debian
# # instead of Alpine to avoid DNS resolution issues in production.
# #
# # https://hub.docker.com/r/hexpm/elixir/tags?page=1&name=ubuntu
# # https://hub.docker.com/_/ubuntu?tab=tags
# #
# # This file is based on these images:
# #
# #   - https://hub.docker.com/r/hexpm/elixir/tags - for the build image
# #   - https://hub.docker.com/_/debian?tab=tags&page=1&name=bullseye-20231009-slim - for the release image
# #   - https://pkgs.org/ - resource for finding needed packages
# #   - Ex: hexpm/elixir:1.16.0-erlang-26.2.1-debian-bullseye-20231009-slim
# #
# # Arguments to define versions
# ARG ELIXIR_VERSION=1.16.0
# ARG OTP_VERSION=26.0
# ARG DEBIAN_VERSION=bullseye-20231009-slim
# ARG NODE_VERSION=16.x

# # Define the builder image based on the versions defined above
# ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-debian-${DEBIAN_VERSION}"
# ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
# ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

# # Use the Elixir-based builder image for building dependencies and assets
# FROM ${BUILDER_IMAGE} AS builder

# # Install build dependencies (git, curl, build tools, nodejs, npm, etc.)
# RUN apt-get update -y && apt-get install -y \
#     build-essential \
#     git \
#     curl \
#     locales \
#     && apt-get clean && rm -rf /var/lib/apt/lists/*

# # Install Node.js 16.x (if not already part of the base image)
# RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION} | bash - && \
#     apt-get update -y && \
#     apt-get install -y nodejs && \
#     apt-get clean && rm -rf /var/lib/apt/lists/*

# # Set build environment variables
# WORKDIR /app
# ENV MIX_ENV="prod"

# # Install Hex and Rebar
# RUN mix local.hex --force && \
#     mix local.rebar --force

# # Install Elixir dependencies
# COPY mix.exs mix.lock ./
# RUN mix deps.get --only $MIX_ENV
# RUN mkdir config

# COPY config/config.exs config/${MIX_ENV}.exs config/
# RUN mix deps.compile

# # Prepare for asset compilation by copying the project files
# COPY lib lib/
# COPY priv priv/
# COPY assets assets/

# # Install Node.js dependencies (assumed to be in assets/package.json)
# # WORKDIR /poll/assets
# # RUN npm install

# # Run assets setup and deploy (this should handle assets setup, build, and minification)
# RUN mix assets.setup
# RUN mix assets.deploy

# # Compile the Elixir project
# RUN mix compile

# # Prepare the release
# COPY config/runtime.exs config/
# COPY rel rel/
# RUN mix release

# # Final runtime image
# FROM ${RUNNER_IMAGE}

# # Install runtime dependencies for the final image
# RUN apt-get update -y && \
#     apt-get install -y \
#     libstdc++6 \
#     openssl \
#     libncurses5 \
#     locales \
#     ca-certificates \
#     && apt-get clean && rm -rf /var/lib/apt/lists/*

# # Set the locale for the final image
# RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

# # Set environment variables for locale
# ENV LANG en_US.UTF-8
# ENV LANGUAGE en_US:en
# ENV LC_ALL en_US.UTF-8

# # Set the working directory and ensure ownership
# WORKDIR "/app"
# RUN chown nobody /app

# # Set runner environment variables
# ENV MIX_ENV="prod"

# # Copy the release files from the builder stage
# COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/poll ./

# # Ensure no root access, running under a non-privileged user
# USER nobody

# # Set the command to run the application
# CMD ["/app/bin/server"]


# Find eligible builder and runner images on Docker Hub. We use Ubuntu/Debian
# instead of Alpine to avoid DNS resolution issues in production.
#
# https://hub.docker.com/r/hexpm/elixir/tags?page=1&name=ubuntu
# https://hub.docker.com/_/ubuntu?tab=tags
#
# This file is based on these images:
#
#   - https://hub.docker.com/r/hexpm/elixir/tags - for the build image
#   - https://hub.docker.com/_/debian?tab=tags&page=1&name=bullseye-20231009-slim - for the release image
#   - https://pkgs.org/ - resource for finding needed packages
#   - Ex: hexpm/elixir:1.16.0-erlang-26.2.1-debian-bullseye-20231009-slim
#
ARG ELIXIR_VERSION=1.16.1
ARG OTP_VERSION=26.2.1
ARG DEBIAN_VERSION=bullseye-20231009-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} as builder

# install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git curl\
    && apt-get clean && rm -f /var/lib/apt/lists/*_*
RUN cd ~
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs
# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV="prod"

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY priv priv

COPY lib lib

COPY assets assets

RUN mix assets.setup
# compile assets
RUN mix assets.deploy

# Compile the release
RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

COPY rel rel
RUN mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}

RUN apt-get update -y && \
  apt-get install -y libstdc++6 openssl libncurses5 locales ca-certificates \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

# set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/poll ./

USER nobody

# If using an environment that doesn't automatically reap zombie processes, it is
# advised to add an init process such as tini via `apt-get install`
# above and adding an entrypoint. See https://github.com/krallin/tini for details
# ENTRYPOINT ["/tini", "--"]

CMD ["/app/bin/server"]