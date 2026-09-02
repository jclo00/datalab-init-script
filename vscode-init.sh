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

# Variante Marketplace, si la version Open VSX est trop ancienne ou
# incompatible avec la version de code-server de l'image (voir le README) :
# CLAUDE_EXT_VERSION="2.0.1"
# wget --retry-on-http-error=429 \
#     "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/Anthropic/vsextensions/claude-code/${CLAUDE_EXT_VERSION}/vspackage" \
#     -O claude-code.vsix.gz
# gzip -d claude-code.vsix.gz
# code-server --install-extension claude-code.vsix
# rm -f claude-code.vsix

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
