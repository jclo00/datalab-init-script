#!/bin/bash


# --------------------------------------------------------------------------- #
# 1. PlantUML                                                                 #
# --------------------------------------------------------------------------- #

# jebbs.plantuml est publiee sur Open VSX : installation directe
code-server --install-extension jebbs.plantuml

# Le rendu local a besoin de Java et de Graphviz, absents des images VSCode
# du datalab. conda evite d'avoir besoin des droits root.
conda install -y -q -c conda-forge openjdk graphviz

# --------------------------------------------------------------------------- #
# 2. Claude Code                                                              #
# --------------------------------------------------------------------------- #

# CLI `claude`, sur laquelle s'appuie l'extension -> ~/.local/bin/claude
curl -fsSL https://claude.ai/install.sh | bash

# ~/.local/bin n'est pas toujours dans le PATH des terminaux du service
if ! grep -q 'HOME/.local/bin' "${HOME}/.bashrc" 2>/dev/null; then
    echo 'export PATH="${HOME}/.local/bin:${PATH}"' >> "${HOME}/.bashrc"
fi

# Extension, version Open VSX (souvent quelques versions en retard)
code-server --install-extension anthropic.claude-code

# Court-circuiter l'assistant de premier lancement (pod ephemere)
CLAUDE_CONFIG="${HOME}/.claude.json"
[ -f "${CLAUDE_CONFIG}" ] || echo "{}" > "${CLAUDE_CONFIG}"

jq '. + {"hasCompletedOnboarding": true}
    | .projects["/home/onyxia/work"].hasTrustDialogAccepted = true' \
    "${CLAUDE_CONFIG}" > "${CLAUDE_CONFIG}.tmp" && mv "${CLAUDE_CONFIG}.tmp" "${CLAUDE_CONFIG}"

# --------------------------------------------------------------------------- #
# 3. Reglages VSCode                                                          #
# --------------------------------------------------------------------------- #

SETTINGS_FILE="${HOME}/.local/share/code-server/User/settings.json"

if [ ! -f "${SETTINGS_FILE}" ]; then
    mkdir -p "$(dirname "${SETTINGS_FILE}")"
    echo "{}" > "${SETTINGS_FILE}"
fi

jq '. + {
    "plantuml.render": "Local",
    "plantuml.exportFormat": "svg",
    "plantuml.previewAutoUpdate": true
}' "${SETTINGS_FILE}" > "${SETTINGS_FILE}.tmp" && mv "${SETTINGS_FILE}.tmp" "${SETTINGS_FILE}"

# Filet de securite : si le script tourne en root, rendre la main a l'utilisateur
if [ "$(id -u)" = "0" ]; then
    chown -R onyxia:users "${HOME}/.local" "${HOME}/.bashrc"
fi
