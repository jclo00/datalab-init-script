#!/usr/bin/bash
set -e

EXT_DIR="${HOME}/.local/share/code-server/extensions"
TARGET="streetsidesoftware.code-spell-checker"

mkdir -p "${EXT_DIR}"

(
    for i in $(seq 1 20); do
        sleep 2
        rm -rf ${EXT_DIR}/${TARGET}* 2>/dev/null || true
    done
) &


USER_SETTINGS="${HOME}/.local/share/code-server/User/settings.json"
mkdir -p "$(dirname "$USER_SETTINGS")"

if [ ! -f "$USER_SETTINGS" ]; then
    echo "{}" > "$USER_SETTINGS"
fi

tmpfile=$(mktemp)
jq '. + { "workbench.colorTheme": "Default Dark Modern",
           "extensions.ignoreRecommendations": true }' \
   "$USER_SETTINGS" > "$tmpfile"

mv "$tmpfile" "$USER_SETTINGS"

#Nécessaire d'après la doc onyxia
chown -R "${USERNAME}:${GROUPNAME}" "${HOME}"
