from debian:latest

ENV USERNAME="neovim-user"
ENV AS_USER="su - $USERNAME -c"
ENV YADM_REPO_URL="https://github.com/vck3000/dotfiles.git"
ENV TERM="screen-256color"

RUN apt-get update && apt-get install -y \
  build-essential \
  curl \
  fzf \
  git \
  locales \
  neovim \
  python3 \
  ripgrep \
  sudo \
  tmux \
  yadm \
  xclip \
  zsh \
 && rm -rf /var/lib/apt/lists/*

# Create local user and add to sudoers
RUN adduser --disabled-password $USERNAME; usermod -aG sudo $USERNAME
# Disable require password to sudo
RUN echo "\n$USERNAME     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set the locale so unicode characters show up correctly in tmux
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
  locale-gen && \
  update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US:en

# Set zsh as default shell
RUN sudo chsh -s $(which zsh) $USERNAME

# Clone my dotfiles. Note double quotes needed here to substitute env varable in.
RUN $AS_USER "yadm clone $YADM_REPO_URL"

# oh-my-zsh
RUN $AS_USER 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
# zsh-autosuggestions
RUN $AS_USER 'git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions'
# zsh-syntax-highlighting
RUN $AS_USER 'git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting'

# Power10k
RUN $AS_USER 'git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k'
# Also download gitstatusd into the cache dir, since this can't always be downloaded
# behind a firewall
RUN $AS_USER 'mkdir -p ~/.cache/gitstatus/ ; \
  curl -L -o ~/.cache/gitstatus/gitstatusd-linux-x86_64.tar.gz \
  https://github.com/romkatv/gitstatus/releases/download/v1.5.4/gitstatusd-linux-x86_64.tar.gz; \
  tar -xzvf ~/.cache/gitstatus/gitstatusd-linux-x86_64.tar.gz -C ~/.cache/gitstatus/; \
  rm ~/.cache/gitstatus/gitstatusd-linux-x86_64.tar.gz'

# Reset yadm as zsh installation overwrites .zshrc
RUN $AS_USER 'yadm reset --hard'

# Languages
# NVM & Node
RUN $AS_USER 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash;'
# Source nvm and then install node.
RUN $AS_USER ". /home/$USERNAME/.nvm/nvm.sh; nvm install --lts"

# Download and install latest stable neovim
RUN $AS_USER 'curl -L -o ~/nvim-linux64.tar.gz \
  https://github.com/neovim/neovim/releases/download/v0.7.0/nvim-linux64.tar.gz; \
  tar -xzf ~/nvim-linux64.tar.gz; \
  rm ~/nvim-linux64.tar.gz;'

# Link in nvim to /usr/bin. Have to separate this line out since it requires root permissions.
RUN rm /usr/bin/nvim; ln -s /home/$USERNAME/nvim-linux64/bin/nvim /usr/bin/nvim

# Install language serveres
# Typescript
RUN $AS_USER ". /home/$USERNAME/.nvm/nvm.sh; npm install -g typescript typescript-language-server"

# C and C++
RUN apt-get update && apt-get install -y \
  ccls \
  clang \
  clangd \
 && rm -rf /var/lib/apt/lists/*

# Pyright - Python
RUN $AS_USER ". /home/$USERNAME/.nvm/nvm.sh; npm install -g pyright"

# Install Neovim packages
# Note: There may be 'cmp not found' errors at the top of this command's output. Ignore them!
RUN $AS_USER 'nvim --headless -c "autocmd User PackerComplete quitall" -c "PackerSync"'

CMD su - $USERNAME -c "/bin/zsh"
# CMD tail -f /dev/null

# TODO: 
# - Add lua LSP server
# - Look into using zplug
# - Add Go!
# - Add Rust!
# - Slim down the docker image
# - Suppress or make lesser the big prompt from powerlevel10k for stdout on zsh startup
# - Test and add instructions for adding/mounting clangd/Python libraries into the container 
#   for intellisense to operate.
