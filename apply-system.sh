#!/bin/sh
pushd ~/config
sudo nixos-rebuild switch -I nixos-config=./configuration.nix
popd
