# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if zsh is installed and do nothing if not
if ! command -v zsh >/dev/null 2>&1; then
  echo "zsh is not installed. Please install zsh and rerun this script."
  exit 1
fi

sudo chsh -s $(which zsh) $USER

if [ -d "$HOME/.oh-my-zsh" ]; then
  # Oh My Zsh 已安装
  # 通过 Oh My Zsh 安装 zsh-autosuggestions zsh-syntax-highlighting
  zsh -c 'git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions'
  zsh -c 'git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting'
  sed -i 's/^plugins=(.*)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
  cat "${SCRIPT_DIR}/alias/git.sh" >> ~/.zshrc
else
  echo "Oh My Zsh 未安装"
fi
