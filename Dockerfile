FROM node:16-slim

## Set to a non-root built-in user `node`
#USER node
#
## https://stackoverflow.com/a/71149283/2052750
#ENV NPM_CONFIG_PREFIX=/home/node/.npm-global


# Create app directory (with user `node`)
RUN mkdir -p /home/node/app

WORKDIR /home/node/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY --chown=node index* ./
COPY --chown=node package*.json ./
COPY --chown=node *.rom ./
COPY --chown=node *.qed ./
COPY --chown=node *.wasm ./

RUN npm install --save pcejs-ibmpc pcejs-util
COPY node_modules/pcejs-ibmpc/ibmpc-pcex.rom ./ibmpc-pcex.rom 
RUN npm install -g browserify@4.x && npm install -g http-server
RUN browserify index.js --noparse="node_modules/pcejs-ibmpc/lib/pcejs-ibmpc.js" > bundle.js 
# RUN npm install http-server

RUN npm install


# Bundle app source code
COPY --chown=node . .

# Bind to all network interfaces so that it can be mapped to the host OS
ENV HOST=0.0.0.0 PORT=8080

EXPOSE ${PORT}

EXPOSE 8080

# CMD ["browserify", "index.js", "--noparse=\"node_modules/pcejs-ibmpc/lib/pcejs-ibmpc.js\" > bundle.js", "&&",  "http-server", "."]
CMD ["http-server", "."]
