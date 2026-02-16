# gh-clean-artifacts

A GitHub CLI extension to trim GitHub Actions artifacts, helping you manage storage limits and costs.

## Features

-   **Retention Policy**: Retains recent artifacts (default: 7 days) regardless of size.
-   **Size Limit**: Deletes older artifacts once the total size exceeds your specified limit (default: 400 MB).
-   **Safe Cleanup**: Processes artifacts from newest to oldest. Recent artifacts are always kept. Older artifacts are kept until the storage limit is reached, then the rest are deleted.
-   **Dry Run / Interactive**: Currently, it performs deletions immediately but prints detailed logs. (Consider adding a dry-run flag in future versions).
-   **Robust**: Written in Python, avoiding shell pipe issues and providing clear statistics.

## Installation

This tool is designed to be used as a `gh` extension.

```bash
gh extension install <your-username>/gh-clean-artifacts
```

Or run locally:

```bash
# Ensure it is executable
chmod +x gh-clean-artifacts

# Run directly
./gh-clean-artifacts --limit 100 --days 7
```

## Usage

```bash
gh clean-artifacts [options]
```

### Options

| Flag | Description | Default |
| :--- | :--- | :--- |
| `-l`, `--limit` | Storage limit in MB. Artifacts exceeding this (excluding recent ones) are deleted. | `400` |
| `-d`, `--days` | Minimum retention period in days. Artifacts newer than this are **always** kept. | `7` |
| `-h`, `--help` | Show help message. | |

### Examples

**Keep 500MB of artifacts, but always keep the last 14 days:**

```bash
gh clean-artifacts --limit 500 --days 14
```

**Strict cleanup: Keep only 100MB, deleting everything else (even recent items):**

```bash
gh clean-artifacts --limit 100 --days 0
```

**Standard cleanup (400MB limit, 7 days retention):**

```bash
gh clean-artifacts
```

## How it works

1.  **Fetches** all artifacts for the current repository.
2.  **Sorts** them by creation date (newest first).
3.  **Iterates** through the list:
    -   If an artifact is **newer** than `--days`, it is **kept**.
    -   If the running total size is **under** `--limit`, it is **kept**.
    -   Otherwise, it is **deleted**.

## Requirements

-   [GitHub CLI (`gh`)](https://cli.github.com/)
-   Python 3
