#!/usr/bin/bash
set -e

CS_USERDIR="${HOME}/.local/share/code-server"
CS_EXTDIR="${CS_USERDIR}/extensions"
CS_USERSET="${CS_USERDIR}/User"
SETTINGS="${CS_USERSET}/settings.json"

mkdir -p "${CS_EXTDIR}"
mkdir -p "${CS_USERSET}"


if command -v code-server >/dev/null 2>&1; then
    code-server --uninstall-extension streetsidesoftware.code-spell-checker || true
fi


rm -rf "${CS_EXTDIR}/streetsidesoftware.code-spell-checker"* 2>/dev/null || true

if [ ! -f "${SETTINGS}" ]; then
    echo "{}" > "${SETTINGS}"
fi

tmpfile=$(mktemp)
jq '. + { "workbench.colorTheme": "Default Dark Modern" }' \
   "${SETTINGS}" > "${tmpfile}"

mv "${tmpfile}" "${SETTINGS}"


##Nécessaire d'après la doc onyxia
chown -R "${USERNAME}:${GROUPNAME}" "${HOME}"
