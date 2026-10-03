#!/bin/sh
echo "Installing Lua 5.4..."
sudo apt install lua5.4 liblua5.4-dev
echo "Installing LuaRocks..."
sudo apt install luarocks
echo "Installing titogramlua..."
sudo luarocks-5.4 install titogramlua