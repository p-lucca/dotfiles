#!/bin/bash

# Exit immediately if any command exits with a non-zero status
set -e

hyprctl --instance 0 'keyword misc:allow_session_lock_restore 1'
hyprctl --instance 0 'dispatch exec hyprlock'

exit
