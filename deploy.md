# Step 1
npm install

# Install Foundry and forge if not present

curl -L https://foundry.paradigm.xyz | bash

source ~/.bashrc or ~/.zshrc depending on your system

foundryup

# Step 3 
npm run contract:compile

forge build 

docker compose up -d

npm run graph:compile:amoy

npm run graph:deploy:amoy