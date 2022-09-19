#!/bin/bash

# up=$(uptime | awk -F " " '{print $3" "$4" "$5}' | rev | cut -c 2- | rev)
up=$(uptime -p)
echo "  "$up
