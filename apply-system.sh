#!/bin/sh

function areSecretsLocked {
    git ls-tree -r --name-only -z HEAD secrets/* | xargs -0 grep -qsPa "\x00GITCRYPT"
}

function unlockSecrets {
    if areSecretsLocked; then
        echo "Unlocking secrets"
        git crypt unlock
    fi
}

pushd ~/config > /dev/null

if ! unlockSecrets; then
    exit 1
fi

sudo nixos-rebuild switch -I nixos-config=./configuration.nix
popd > /dev/null

