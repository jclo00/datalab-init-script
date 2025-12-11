#!/usr/bin/bash
set -e

USER_SETTINGS="${HOME}/.local/share/code-server/User/settings.json"
mkdir -p "$(dirname "$USER_SETTINGS")"

if [ ! -f "$USER_SETTINGS" ]; then
    echo "{}" > "$USER_SETTINGS"
fi

tmpfile=$(mktemp)
jq '. + { "workbench.colorTheme": "Default Dark Modern",
           "extensions.ignoreRecommendations": true,
           "extensions.disabled": [
            "streetsidesoftware.code-spell-checker"
        ]
    }' "$USER_SETTINGS" > "$tmpfile"

mv "$tmpfile" "$USER_SETTINGS"

#Nécessaire d'après la doc onyxia
chown -R "${USERNAME}:${GROUPNAME}" "${HOME}"
