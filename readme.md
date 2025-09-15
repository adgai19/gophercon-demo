```bash
nix build .#gophercon-demo # builds the binary

nix build .#gophercon-demo-image # builds the container

docker load < result # loads the results into docker

 docker run --rm gophercon-demo:0.0.1 # runs the docker container
```
