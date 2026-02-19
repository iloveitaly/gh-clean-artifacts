# Manage GitHub Artifacts

Managing GitHub Actions artifacts can be a pain. I realized I was hoarding gigabytes of old build logs and binaries I'd never look at again. It felt like digital clutter taking up mental space—and actual storage quota. So I wrote this extension. It keeps your recent artifacts safe while ruthlessly pruning the old stuff once you hit a size limit. Think of it as a garbage collector for your CI/CD pipeline.

## Installation

You can install this directly as a GitHub CLI extension. It's the easiest way to get it running in your workflow.

```bash
gh extension install <your-username>/gh-clean-artifacts
```

If you prefer running it locally or hacking on it, `uv` is your best friend here.

```bash
# Make the script executable
chmod +x gh-clean-artifacts

# Run with uv
uv run gh-clean-artifacts --help
```

## Usage

The defaults are sane: keep 7 days of history, but cap the total size at 400MB. If you're running a lean operation, you might want to tighten that up.

```bash
gh clean-artifacts --limit 100 --days 3
```

This tells the script: "Keep the last 3 days no matter what, but purge anything else if the total folder size exceeds 100MB."

## Features

*   **Smart Retention**: Always keeps your newest artifacts within the window you define (default is 7 days).
*   **Size Capping**: Enforces a hard limit on total storage (default 400MB), deleting the oldest artifacts first once the safety window is passed.
*   **GitHub CLI Native**: Integrates seamlessly as a `gh` extension, so you don't need to juggle API tokens manually.
*   **Verbose Logging**: Prints detailed information about every artifact it keeps or deletes, so you have a complete audit trail of what happened.

## ⚠️ Warning

**This tool deletes data permanently.**

There is no "undo" bin for GitHub Artifacts. Once this script runs, the artifacts exceeding your limits are gone. I highly recommend running with a generous `--limit` first to see how much space you are actually using before tightening the screws.

## Automation

Since the GitHub CLI is already baked into `ubuntu-latest` (and most other runners), you don't have to install anything extra. It's the perfect "set and forget" task. You can drop a workflow file like this into `.github/workflows/cleanup.yml`:

```yaml
name: Cleanup Artifacts
on:
  schedule:
    - cron: '0 0 * * *' # Run daily at midnight
  workflow_dispatch:

jobs:
  cleanup:
    runs-on: ubuntu-latest
    permissions:
      actions: write
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Run Cleanup
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          # Install the extension
          gh extension install iloveitaly/gh-clean-artifacts
          
          # Run it
          gh clean-artifacts --limit 500 --days 7
```

## How it works

The logic is strictly prioritized to save your most recent work while respecting your storage cap:

1.  **Retention Window**: Any artifact newer than `--days` (default: 7) is **kept**, period. Even if you have 10GB of artifacts from yesterday, they stay.
2.  **Size Limit**: For artifacts *older* than the retention window, we keep them until the *total* size of all artifacts (new + old) hits the `--limit` (default: 400MB).
3.  **Cleanup**: Once the limit is reached, the remaining older artifacts are deleted, starting from the oldest.

## Related Projects

* [github-action-nixpacks](https://github.com/iloveitaly/github-action-nixpacks): Build and push images with nixpacks
* [playwright-trace-analyzer](https://github.com/iloveitaly/playwright-trace-analyzer): CLI tool for analyzing Playwright trace files without the browser-based viewer
* [pytest-plugin-utils](https://github.com/iloveitaly/pytest-plugin-utils): Reusable configuration and artifact utilities for building pytest plugins

## [MIT License](LICENSE.md)
