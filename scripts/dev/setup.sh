#!/bin/sh

set -e

mix ecto.create
mix ecto.migrate
mix phx.server
