#!/bin/bash

function promtoolCheckConfig {
  echo "rules: info: checking if Prometheus config files are valid or not"
  checkconfigOut=$(promtool check config ${promtoolFlags} ${promFiles} ${*} 2>&1)
  checkconfigExitCode=${?}

  # Exit code of 0 indicates success. Print the output and exit.
  if [ ${checkconfigExitCode} -eq 0 ]; then
    echo "checkconfig: info: Prometheus config files ${promFiles} are valid."
    echo "${checkconfigOut}"
    echo
    checkconfigCommentStatus="Success"
  fi

  # Exit code of !0 indicates failure.
  if [ ${checkconfigExitCode} -ne 0 ]; then
    echo "checkconfig: error: Prometheus config files ${promFiles} are invalid."
    echo "${checkconfigOut}"
    echo
    checkconfigCommentStatus="Failed"
  fi

  # Comment on the pull request if necessary.
  if [ "$GITHUB_EVENT_NAME" == "pull_request" ] && [ "${promtoolComment}" == "1" ]; then
     checkconfigCommentWrapper="#### \`promtool check config\` ${checkconfigCommentStatus}
<details><summary>Show Output</summary>

\`\`\`
${checkconfigOut}
\`\`\`

</details>

*Workflow: \`${GITHUB_WORKFLOW}\`, Action: \`${GITHUB_ACTION}\`, Files: \`${promFiles}\`*"

    echo "checkconfig: info: creating JSON"
    checkconfigPayload=$(echo "${checkconfigCommentWrapper}" | jq -R --slurp '{body: .}')
    checkconfigCommentsURL=$(cat ${GITHUB_EVENT_PATH} | jq -r .pull_request.comments_url)
    echo "checkconfig: info: commenting on the pull request"
    echo "${checkconfigPayload}" | curl -s -S -H "Authorization: token ${GITHUB_TOKEN}" --header "Content-Type: application/json" --data @- "${checkconfigCommentsURL}" > /dev/null
  fi

  exit ${checkconfigExitCode}
}
