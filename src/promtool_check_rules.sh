#!/bin/bash

function promtoolCheckRules {
  echo "rules: info: checking if Prometheus alert rule files are valid or not"
  checkRulesOut=$(promtool check rules ${promtoolFlags} ${promFiles} ${*} 2>&1)
  checkRulesExitCode=${?}

  # Exit code of 0 indicates success. Print the output and exit.
  if [ ${checkRulesExitCode} -eq 0 ]; then
    echo "checkRules: info: Prometheus alert rule files ${promFiles} are valid."
    echo "${checkRulesOut}"
    echo
    checkRulesCommentStatus="Success"
  fi

  # Exit code of !0 indicates failure.
  if [ ${checkRulesExitCode} -ne 0 ]; then
    echo "checkRules: error: Prometheus alert rule files ${promFiles} are invalid."
    echo "${checkRulesOut}"
    echo
    checkRulesCommentStatus="Failed"
  fi

  # Comment on the pull request if necessary.
  if [ "$GITHUB_EVENT_NAME" == "pull_request" ] && [ "${promtoolComment}" == "1" ]; then
     checkRulesCommentWrapper="#### \`promtool check rules\` ${checkRulesCommentStatus}
<details><summary>Show Output</summary>

\`\`\`
${checkRulesOut}
\`\`\`

</details>

*Workflow: \`${GITHUB_WORKFLOW}\`, Action: \`${GITHUB_ACTION}\`, Files: \`${promFiles}\`*"

    echo "checkRules: info: creating JSON"
    checkRulesPayload=$(echo "${checkRulesCommentWrapper}" | jq -R --slurp '{body: .}')
    checkRulesCommentsURL=$(cat ${GITHUB_EVENT_PATH} | jq -r .pull_request.comments_url)
    echo "checkRules: info: commenting on the pull request"
    echo "${checkRulesPayload}" | curl -s -S -H "Authorization: token ${GITHUB_TOKEN}" --header "Content-Type: application/json" --data @- "${checkRulesCommentsURL}" > /dev/null
  fi

  exit ${checkRulesExitCode}
}
