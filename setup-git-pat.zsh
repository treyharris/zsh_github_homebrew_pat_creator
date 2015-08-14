# Need a token for homebrew calls to GitHub.
function {
  local _homebrew_github_pat_file=~/.homebrew-github-token
  if [[ -f "${_homebrew_github_pat_file}" ]]; then
    export HOMEBREW_GITHUB_API_TOKEN=$(cat "${_homebrew_github_pat_file}")
  elif _is_interactive_shell; then
    export HOMEBREW_GITHUB_PAT_FILE="${_homebrew_github_pat_file}"
    echoerr \
"No GitHub Personal Access Token for Homebrew. You may be rate-limited.
Run 'homebrew_github_token' for details."

    # We make this a function so that if this happens on a new

    function homebrew_github_token {
      if [[ -f "${HOMEBREW_GITHUB_PAT_FILE}" ]]; then
        export HOMEBREW_GITHUB_API_TOKEN=$(cat "${_homebrew_github_pat_file}")
        echoerr "Installed GitHub Personal Access Token for Homebrew."
      else
        echoerr \
"You have no ${HOMEBREW_GITHUB_PAT_FILE}. To create it,
you must go to the GitHub Personal Authentication Token (PAT) page,
and create a new token. Until then, you may be rate-limited,
preventing updates to Homebrew.

We can send you to your GitHub PAT page; create a new token,
UNCHECKING ALL SCOPE BOXES. Then click 'Generate Token' and copy
the hexadecimal token provided.

"
        if yesno 'Do you want to do this now?'; then
          open 'https://github.com/settings/tokens/new'
          echoerr "Enter the generated token below. Enter 'q' to cancel."
          local _token
          until promptNonNull 'Generated token from GitHub> ' _token
          do
            echoerr 'Try again, or enter q to cancel.'
          done

          if [[ "${_token}" == "q" ]]; then
            echoerr 'Cancelled. Run homebrew_github_token again when ready.'
          elif [[ "${_token}" =~ '^[0-9a-f]{40}$' ]]; then
            echo -n "${_token}" > ${HOMEBREW_GITHUB_PAT_FILE}
            export HOMEBREW_GITHUB_API_TOKEN="${_token}"
            echoerr 'Token successfully installed.'
          else
            echoerr "The token:
  ${_token}
is not a 40-digit hexadecimal? Aborting."
          fi
        fi
      fi

    }
  fi

}

# For GitHub auth
export GITHUB_USER=treyharris

# brew install hub, see http://hub.github.com/
if (( $+commands[hub] )) ; then
  eval "$(hub alias -s)"
fi
