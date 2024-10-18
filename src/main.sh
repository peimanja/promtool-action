#!/bin/bash

function parseInputs {
  # Required inputs
  if [ "${INPUT_PROMTOOL_ACTIONS_FILES}" != "" ]; then
    promFiles=${INPUT_PROMTOOL_ACTIONS_FILES}
  else
    echo "Input promtool_files cannot be empty"
    exit 1
  fi

  if [ "${INPUT_PROMTOOL_ACTIONS_SUBCOMMAND}" != "" ]; then
    promtoolSubcommand=${INPUT_PROMTOOL_ACTIONS_SUBCOMMAND}
  else
    echo "Input promtool_subcommand cannot be empty"
    exit 1
  fi

  promtoolFlags=""
  if [ "${INPUT_PROMTOOL_ACTIONS_FLAGS}" != "" ]; then
    promtoolFlags=${INPUT_PROMTOOL_ACTIONS_FLAGS}
  fi

  # Optional inputs
  promtoolVersion="latest"
  if [ "${INPUT_PROMTOOL_ACTIONS_VERSION}" != "" ] || [ "${INPUT_PROMTOOL_ACTIONS_VERSION}" != "latest" ]; then
    promtoolVersion=${INPUT_PROMTOOL_ACTIONS_VERSION}
  fi

  promtoolComment=0
  if [ "${INPUT_PROMTOOL_ACTIONS_COMMENT}" == "1" ] || [ "${INPUT_PROMTOOL_ACTIONS_COMMENT}" == "true" ]; then
    promtoolComment=1
  fi
}


function installPromtool {
  if [[ "${promtoolVersion}" == "latest" ]]; then
    echo "Checking the latest version of Promtool"
    promtoolVersion=$(git ls-remote --tags --refs --sort="v:refname"  https://github.com/prometheus/prometheus | grep -v '[-].*' | tail -n1 | sed 's/.*\///' | cut -c 2-)
    if [[ -z "${promtoolVersion}" ]]; then
      echo "Failed to fetch the latest version"
      exit 1
    fi
  fi

  
  url="https://github.com/prometheus/prometheus/releases/download/v${promtoolVersion}/prometheus-${promtoolVersion}.linux-amd64.tar.gz"

  echo "Downloading Promtool v${promtoolVersion}"
  curl -s -S -L -o /tmp/promtool_${promtoolVersion} ${url}
  if [ "${?}" -ne 0 ]; then
    echo "Failed to download Promtool v${promtoolVersion}"
    exit 1
  fi
  echo "Successfully downloaded Promtool v${promtoolVersion}"

  echo "Unzipping Promtool v${promtoolVersion}"
  tar -zxf /tmp/promtool_${promtoolVersion} --strip-components=1 --directory /usr/local/bin &> /dev/null
  if [ "${?}" -ne 0 ]; then
    echo "Failed to unzip Promtool v${promtoolVersion}"
    exit 1
  fi
  echo "Successfully unzipped Promtool v${promtoolVersion}"
}

function main {
  # Source the other files to gain access to their functions
  scriptDir=$(dirname ${0})
  source ${scriptDir}/promtool_check_rules.sh
  source ${scriptDir}/promtool_check_config.sh

  parseInputs
  cd ${GITHUB_WORKSPACE}

  case "${promtoolSubcommand}" in
    config)
      installPromtool
      promtoolCheckConfig ${*}
      ;;
    rules)
      installPromtool
      promtoolCheckRules ${*}
      ;;
    *)
      echo "Error: Must provide a valid value for promtool_subcommand"
      exit 1
      ;;
  esac
}

main "${*}"
