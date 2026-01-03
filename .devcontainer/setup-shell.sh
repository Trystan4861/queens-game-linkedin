#!/bin/sh
set -e

echo "▶ Installing base packages..."
apk add --no-cache git curl bash zsh

# ---------- Oh My Zsh ----------
if [ ! -d "/root/.oh-my-zsh" ]; then
  echo "▶ Installing Oh My Zsh..."
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM=${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}

# ---------- Powerlevel10k ----------
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  echo "▶ Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "$ZSH_CUSTOM/themes/powerlevel10k"
fi

# ---------- Plugins ----------
install_plugin() {
  NAME=$1
  REPO=$2
  if [ ! -d "$ZSH_CUSTOM/plugins/$NAME" ]; then
    git clone "$REPO" "$ZSH_CUSTOM/plugins/$NAME"
  fi
}

echo "▶ Installing Zsh plugins..."
install_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions
install_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting

# ---------- Configure .zshrc ----------
echo "▶ Configuring .zshrc..."

sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' /root/.zshrc

sed -i 's|^plugins=.*|plugins=(git node npm zsh-autosuggestions zsh-syntax-highlighting)|' \
  /root/.zshrc

# ---------- Powerlevel10k instant prompt (fast startup) ----------
grep -q "p10k-instant-prompt" /root/.zshrc || cat << 'EOF' >> /root/.zshrc

# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
EOF

echo "✅ Shell setup completed"
