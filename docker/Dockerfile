# Builder stage - compile contracts
FROM node:20 AS builder

RUN apt-get update && apt-get install -y curl git build-essential

WORKDIR /app
COPY . .

# Install Foundry properly
RUN curl -L https://foundry.paradigm.xyz | bash
RUN bash -i -c "source /root/.bashrc && foundryup && /root/.cargo/bin/forge --version"

# Install dependencies
RUN npm install

# Build contracts using Foundry
RUN bash -i -c "source /root/.bashrc && /root/.cargo/bin/forge build"

# Compile contracts using Hardhat
RUN bash -i -c "source /root/.bashrc && npx hardhat compile"

# Runtime stage
FROM node:20-alpine

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm install

COPY . .

# Copy compiled contracts from builder
COPY --from=builder /app/out ./out
COPY --from=builder /app/artifacts ./artifacts
COPY --from=builder /app/cache ./cache
COPY --from=builder /app/cache_forge ./cache_forge