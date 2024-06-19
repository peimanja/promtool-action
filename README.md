# Promtool GitHub Actions

Promtool GitHub Actions allow you to check Prometheus configs and Alert rules within GitHub Actions.

The output of the actions can be viewed from the Actions tab in the main repository view. If the actions are executed on a pull request event, a comment may be posted on the pull request.

## Success Criteria

An exit code of `0` is considered a successful execution.

## Usage

Promtool GitHub Actions are a single GitHub Action that executes different promtool subcommands depending on the content of the GitHub Actions YAML file. Right now only `rules`, `config` or `test` is supported which runs `promtool check rules`, `promtool check config` or ` promtool test rules` for the given files.

```yaml
name: Check Prometheus Alert rules

on:
  pull_request:
    paths:
    - 'prometheus/config/*.yml'
    - 'prometheus/alert_rules/*.yml'

jobs:
  on-pull-request:
    name: On Pull Request
    runs-on: ubuntu-latest
    steps:
    - name: Checkout Repo
      uses: actions/checkout@master

    - name: Check Prometheus alert rules
      uses: peimanja/promtool-github-actions@master
      with:
        promtool_actions_subcommand: 'rules'
        promtool_actions_files: 'prometheus/alert_rules/*.yml'
        promtool_actions_version: '2.14.0'
        promtool_actions_comment: true
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

    - name: Check Prometheus configs
      uses: peimanja/promtool-github-actions@master
      with:
        promtool_actions_subcommand: 'config'
        promtool_actions_files: 'prometheus/config/*.yml'
        promtool_actions_version: '2.14.0'
        promtool_actions_comment: true
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

    - name: Test Prometheus rules
      uses: peimanja/promtool-github-actions@master
      with:
        promtool_actions_subcommand: 'test'
        promtool_actions_files: 'prometheus/tests/*.yml'
        promtool_actions_version: '2.14.0'
        promtool_actions_comment: true
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Inputs

Inputs configure Terraform GitHub Actions to perform different actions.

* `promtool_actions_subcommand` - (Required) The Promtool subcommand to execute. Valid values are `rules`, `config` and `test`.
* `promtool_actions_files` - (Required) Path to files. Can be something like `configs/*.yml`, `alert_rules/*.yml` or `tests/*.yml`.
* `promtool_actions_version` - (Optional) The Promtool version to install and execute (Prometheus bundle version). The default is set to `latest` and the latest stable version will be pulled down automatically.
* `promtool_actions_comment` - (Optional) Whether or not to comment on GitHub pull requests. Defaults to `true`.

## Secrets

Secrets are similar to inputs except that they are encrypted and only used by GitHub Actions. It's a convenient way to keep sensitive data out of the GitHub Actions workflow YAML file.

* `GITHUB_TOKEN` - (Optional) The GitHub API token used to post comments to pull requests. Not required if the `promtool_actions_comment` input is set to `false`.
