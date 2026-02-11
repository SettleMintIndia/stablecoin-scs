# Builder stage - compile contracts
FROM ubuntu:22.04 AS builder

RUN apt-get update && apt-get install -y curl git

WORKDIR /app
COPY . .

# Install Foundry
RUN curl -L https://foundry.paradigm.xyz | bash && \
    bash ~/.foundryup && \
    ~/.cargo/bin/forge build

# Runtime stage
FROM node:20-alpine

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm install

COPY . .
# Copy compiled contracts from builder
COPY --from=builder /app/out ./out