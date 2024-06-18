#!/bin/bash

function promtoolTestRules {
  echo "rules: info: testing if Prometheus rule files are valid or not"
  testRulesOut=$(ls ${promFiles} |	xargs -I{}  promtool test rules {} ${*} 2>&1)
  testRulesExitCode=${?}

  # Exit code of 0 indicates success. Print the output and exit.
  if [ ${testRulesExitCode} -eq 0 ]; then
    echo "testRules: info: Prometheus test succeeded."
    echo "${testRulesOut}"
    echo
    testRulesCommentStatus="Success"
  fi

  # Exit code of !0 indicates failure.
  if [ ${testRulesExitCode} -ne 0 ]; then
    echo "testRules: error: Prometheus test failed."
    echo "${testRulesOut}"
    echo
    testRulesCommentStatus="Failed"
  fi

  # Comment on the pull request if necessary.
  if [ "$GITHUB_EVENT_NAME" == "pull_request" ] && [ "${promtoolComment}" == "1" ]; then
     testRulesCommentWrapper="#### \`promtool test rules\` ${testRulesCommentStatus}
<details><summary>Show Output</summary>

\`\`\`
${testRulesOut}
\`\`\`

</details>

*Workflow: \`${GITHUB_WORKFLOW}\`, Action: \`${GITHUB_ACTION}\`, Files: \`${promFiles}\`*"

    echo "testRules: info: creating JSON"
    testRulesPayload=$(echo "${testRulesCommentWrapper}" | jq -R --slurp '{body: .}')
    testRulesCommentsURL=$(cat ${GITHUB_EVENT_PATH} | jq -r .pull_request.comments_url)
    echo "testRules: info: commenting on the pull request"
    echo "${testRulesPayload}" | curl -s -S -H "Authorization: token ${GITHUB_TOKEN}" --header "Content-Type: application/json" --data @- "${testRulesCommentsURL}" > /dev/null
  fi

  exit ${testRulesExitCode}
}
