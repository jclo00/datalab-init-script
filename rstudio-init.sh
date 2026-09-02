#!/bin/bash


# Les init scripts RStudio peuvent tourner en root : on ne se fie pas a $HOME
USER_HOME="/home/onyxia"

# --------------------------------------------------------------------------- #
# 1. Installation de la CLI                                                   #
# --------------------------------------------------------------------------- #

# HOME est force pour que le binaire aille dans le home de onyxia
# et non dans celui de root -> ${USER_HOME}/.local/bin/claude
curl -fsSL https://claude.ai/install.sh -o /tmp/install-claude.sh
HOME="${USER_HOME}" bash /tmp/install-claude.sh
rm -f /tmp/install-claude.sh

# --------------------------------------------------------------------------- #
# 2. Rendre `claude` accessible depuis le terminal RStudio                    #
# --------------------------------------------------------------------------- #

# Le terminal RStudio n'est pas toujours un shell de login : on couvre les
# deux cas, PATH dans .bashrc et lien dans un repertoire deja dans le PATH
if ! grep -q 'local/bin' "${USER_HOME}/.bashrc" 2>/dev/null; then
    echo 'export PATH="${HOME}/.local/bin:${PATH}"' >> "${USER_HOME}/.bashrc"
fi

if [ "$(id -u)" = "0" ] && [ -x "${USER_HOME}/.local/bin/claude" ]; then
    ln -sf "${USER_HOME}/.local/bin/claude" /usr/local/bin/claude
fi

# --------------------------------------------------------------------------- #
# 3. Court-circuiter l'assistant de premier lancement                         #
# --------------------------------------------------------------------------- #

# Sans ca, `claude` en interactif redemande une methode d'authentification a
# chaque nouveau pod, meme quand CLAUDE_CODE_OAUTH_TOKEN est present.
# Cles internes au produit, non documentees : a verifier apres montee de version.
CLAUDE_CONFIG="${USER_HOME}/.claude.json"

if [ ! -f "${CLAUDE_CONFIG}" ]; then
    cat << EOF > "${CLAUDE_CONFIG}"
{
    "hasCompletedOnboarding": true,
    "projects": {
        "${WORKSPACE_DIR:-/home/onyxia/work}": {
            "hasTrustDialogAccepted": true
        }
    }
}
EOF
fi

# --------------------------------------------------------------------------- #
# 4. Permissions                                                              #
# --------------------------------------------------------------------------- #

if [ "$(id -u)" = "0" ]; then
    chown -R onyxia:users \
        "${USER_HOME}/.local" \
        "${USER_HOME}/.bashrc" \
        "${CLAUDE_CONFIG}"
    [ -d "${USER_HOME}/.claude" ] && chown -R onyxia:users "${USER_HOME}/.claude"
fi

# --------------------------------------------------------------------------- #
# 5. Controle                                                                 #
# --------------------------------------------------------------------------- #

if [ -n "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]; then
    echo "[init] CLAUDE_CODE_OAUTH_TOKEN present"
else
    echo "[init] ATTENTION : CLAUDE_CODE_OAUTH_TOKEN absent de l'environnement"
fi

"${USER_HOME}/.local/bin/claude" --version || echo "[init] echec installation CLI"
