FROM elixir:1.18-alpine

# Install build dependencies
RUN apk add --no-cache build-base git nodejs npm

# Set working directory
WORKDIR /app

# Install hex package manager
RUN mix local.hex --force

# Install rebar
RUN mix local.rebar --force

# Copy mix files
COPY mix.exs mix.lock ./

# Install dependencies
RUN mix deps.get --only prod

# Copy assets
COPY assets ./assets
COPY config ./config
COPY lib ./lib
COPY priv ./priv

# Build assets
RUN mix assets.deploy

# Compile the release
RUN mix compile

# Create release
RUN mix release

# Start the application
CMD ["mix", "phx.server"]