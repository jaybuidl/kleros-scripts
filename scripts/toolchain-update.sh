# Brew
brew update && brew upgrade

# Bun
cd ~/.bun/install/global
bun pm ls
bun upgrade
bun update
cd -


# NPM global packages (from volta)
npm outdated -g
npm update -g

# NPM global packages (from brew)
/opt/homebrew/bin/npm outdated -g
/opt/homebrew/bin/npm update -g

# Rust and Cargo
rustup update

# Foundry
foundryup
cd /tmp
forge completions bash > forge
cast completions bash > cast
anvil completions bash > anvil
sudo mv forge cast anvil $(brew --prefix)/etc/bash_completion.d/
cd -
exec bash

# Python3 pip
python3 -m pip install --upgrade pip

# Python3 pip packages
# adapted from https://stackoverflow.com/questions/2720014/how-to-upgrade-all-python-packages-with-pip
python3 -m pip --disable-pip-version-check list --outdated --format=json \
  | jq -r  '.[].name' \
  | xargs -n1 pip install -U

