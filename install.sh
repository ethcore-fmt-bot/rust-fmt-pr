#!/bin/bash
if ! [ -x "$(command -v cargo)" ]; then
  echo 'cargo/rust is not installed.';
  read -p 'Would you like me to install multirust for ya? [y/N] ' -r

  if [[ $REPLY =~ ^[Yy]$ ]];
  then
    curl -sf https://raw.githubusercontent.com/brson/multirust/master/blastoff.sh | sh || exit 2
  else
    exit 1
  fi
fi

echo "Installing rustfmt"
cargo install rustfmt
