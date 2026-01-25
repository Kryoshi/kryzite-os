[private]
default:
    @just --list

# Init system
[group('setup')]
kryblue-init: kryblue-initialize

[group('setup')]
kryblue-initialize:
  #!/usr/bin/env bash
  set -euo pipefail

  ## starship

  starship_preset="tokyo-night"

  starship preset "$starship_preset" -o ~/.config/starship.toml

  ## ptyxis

  PROFILE=$(gsettings get org.gnome.Ptyxis default-profile-uuid)
  gsettings set org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/${PROFILE:1:-1}/ opacity 0.9

  ## git

  git config --global user.name "Kryoshi"
  git config --global user.email "63922550+Kryoshi@users.noreply.github.com"
  git config --global init.defaultBranch main
  git config --global pull.rebase false
  git config --global core.editor "code"

  read -p "Enter your Git email: " git_email

  if [ ! -f "${HOME}/.ssh/id_ed25519.pub" ]; then
    # Generate SSH key
    echo "SSH key not found"
    echo "Generating SSH key..."
    ssh-keygen -t ed25519 -C "$git_email" -f "$HOME/.ssh/id_ed25519" -N ""

    # Display the public key
    echo "Your SSH public key:"
    cat ${HOME}/.ssh/id_ed25519.pub
  else
    echo "SSH key already exists at ~/.ssh/id_ed25519.pub" -f "$HOME/.ssh/id_ed25519" -N ""
  fi

  ## docker

  echo "Initializing docker..."

  sudo groupadd docker
  sudo usermod -aG docker $USER
  sudo systemctl enable docker.service
  sudo systemctl enable containerd.service

  ## code

  xdg-mime default code.desktop text/plain

  echo "Initialization Complete"

# Install flatpaks
[group('setup')]
kryblue-install: kryblue-install-flatpaks

[group('setup')]
kryblue-install-flatpaks:
  #!/usr/bin/env bash
  set -euo pipefail
  flatpak remote-modify --no-filter --enable flathub
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  
  echo "Installing Flatpaks..."
  flatpak install -y --reinstall flathub $(flatpak list --app-runtime=org.fedoraproject.Platform --columns=application | tail -n +1 )
  flatpak remote-delete -y fedora
  xargs -a <(curl --retry 3 -sL https://raw.githubusercontent.com/Kryoshi/kryzite-os/main/repo_files/flatpaks) flatpak --system -y install
  flatpak uninstall --unused

  echo "Flatpaks installation complete."