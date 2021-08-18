#!/bin/sh

session=sysconfig


function new_session {
  local window_name=$1
  tmux new-session -s $session -n $window_name -d
}

function new_window {
  local window_name=$1
  tmux new-window -t $session -n $window_name
}

function send_keys {
  local session=$1
  local keys=$2
  tmux send-keys -t $1 "$2" C-m
}

function split_vertically {
  tmux split-window -v -t $session 
}

function split_horizontally {
  tmux split-window -h -t $session 
}

function select_layout {
  local layout=$1
  tmux select-layout -t $session $layout
}

tmux has-session -t $session

if [ $? != 0 ]
then
  new_session 'system'

  send_keys $session 'cd ~/config'
  send_keys $session "vim system/configuration.nix"

  split_horizontally
  select_layout "main-vertical"
  send_keys "$session:1.2" "cd ~/config"

  split_vertically
  send_keys "$session:1.3" "man configuration.nix"
  
  new_window "home"
  send_keys "$session:2.1" "cd ~/config/users/marc"
  send_keys "$session:2.1" "vim home.nix"

  split_horizontally
  select_layout "main-vertical"
  send_keys "$session:2.2" "cd ~/config/users/marc"

  split_vertically
  send_keys "$session:2.3" "man home-configuration.nix"

  tmux select-window -t "$session:1"
fi

tmux attach -t $session
