# neovim-docker

This repo contains the Dockerfile to set up my current development environment in full. 

It includes:
- zsh
- powerlevel10k
- neovim
- My dotfiles
- NodeJS, Python3 and Clang
- clangd, ccls, pyright and tsserver language servers
- tmux
- Other misc. tools I use often!

Note this is intended for the x86 architecutre.


## Handy commands:
- Running pre-built image: `docker run --rm -it -v $(pwd):/home/neovim-user/mnt vck3000/neovim`
- Building: `docker build -t <tag_name> .`
- Running: `docker run --rm -it -v $(pwd):/home/<username>/mnt <tag_name>`
- Pushing: `docker push <docker_username>/<tag_name>:<version>`


## Inspiration:
Many other examples contributed to the final shape of my Dockerfile. Here are them in no particular order:

- https://github.com/ljishen/MyVim
- https://github.com/nicodebo/neovim-docker
- https://github.com/nemanjan00/dev-environment
- https://hub.docker.com/r/gianarb/neovim/dockerfile/
- https://github.com/jferrer/neovim-dockerized
- https://github.com/JAremko/alpine-vim
- https://www.reddit.com/r/neovim/comments/mi35nz/comment/gt3spj6/?utm_source=share&utm_medium=web2x&context=3
