FROM node:20-alpine

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm install

COPY . .

# Install foundry dependencies and build contracts
RUN apk add --no-cache curl bash && \
    curl -L https://foundry.paradigm.xyz | bash && \
    bash ~/.foundryup && \
    ~/.cargo/bin/forge build