# cronos-docker
Dockerfile for running a cronos mainnet node 


## Volume for blockchain data 
blockchain data >=~ 1TB, so we need to persist it in case our container goes down.

You should:
create ./cronos_data empty directory before running docker-compose up for the first time 

OR 

provide an already initilized .cronos from somewhere else 


## Run

`docker-compose up -d` 
