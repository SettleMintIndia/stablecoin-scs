# Builder stage - compile contracts
FROM ubuntu:22.04 AS builder

RUN apt-get update && apt-get install -y curl git

WORKDIR /app
COPY . .

# Install Foundry
RUN curl -L https://foundry.paradigm.xyz | bash && \
    bash ~/.foundryup

# Install Node.js in builder
RUN apt-get install -y nodejs npm && \
    npm install

# Build contracts using Foundry
RUN ~/.cargo/bin/forge build

# Compile contracts using Hardhat
RUN npx hardhat compile

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