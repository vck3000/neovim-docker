from debian:latest

ENV USERNAME="victor"
ENV AS_USER="su - $USERNAME -c"
ENV YADM_REPO_URL=https://github.com/vck3000/dotfiles.git

RUN apt-get update && apt-get install -y \
  build-essential \
  curl \
  fzf \
  git \
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

# Language specific things
# NVM
RUN $AS_USER 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash;'
# Source nvm and then install node.
RUN $AS_USER ". /home/$USERNAME/.nvm/nvm.sh; nvm install lts/*"

# Download latest stable neovim
RUN $AS_USER 'curl -L -o ~/nvim-linux64.tar.gz \
  https://github.com/neovim/neovim/releases/download/v0.7.0/nvim-linux64.tar.gz; \
  tar -xzf ~/nvim-linux64.tar.gz; \
  rm ~/nvim-linux64.tar.gz;'

# Link in nvim. Have to separate out since it requires root permissions.
RUN rm /usr/bin/nvim; ln -s /home/$USERNAME/nvim-linux64/bin/nvim /usr/bin/nvim

# Install language serveres
# RUN $AS_USER 'nvim --headless +PackerInstall +q'
RUN echo 'asdf'
RUN $AS_USER 'nvim --headless -c "autocmd User PackerComplete quitall" -c "PackerInstall"'
RUN $AS_USER 'nvim --headless +"LspInstall --sync tsserver" +q'
# RUN $AS_USER 'nvim --headless +"LspInstall --sync ccls" +q'
# RUN $AS_USER 'nvim --headless +"LspInstall --sync clangd" +q'
# RUN $AS_USER 'nvim --headless +"LspInstall --sync pyright" +q'

# RUN apt-get --no-cache add \
#   curl \
#   python3 \
#   neovim \
#   fzf \
#   bash \
#   ripgrep \
#   git \
#   xclip \
#   tzdata \
#   zip \
#   unzip

# Add a local user with sudo permissions
# ENV USERNAME=victor
# RUN adduser -g "${USERNAME}" $USERNAME; echo "$USERNAME ALL=(ALL) ALL" > /etc/sudoers.d/$USERNAME && chmod 0440 /etc/sudoers.d/$USERNAME

# Somehow $USERNAME isn't substituted here.
# CMD ["su", "-", "$USERNAME", "-c", "/bin/zsh"] 

CMD su - $USERNAME -c "/bin/zsh"
