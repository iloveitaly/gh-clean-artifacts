GITHUB_PROTECT_MASTER_RULESET := """
{
  "name": "Protect master from force pushes",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["refs/heads/master"],
      "exclude": []
    }
  },
  "rules": [
    {
      "type": "non_fast_forward"
    }
  ]
}
"""

install:
	gh extension install .

sync-metadata:
	gh repo edit \
		--description "$(jq -r '.description' metadata.json)" \
		--homepage "$(jq -r '.homepage' metadata.json)" \
		--add-topic "$(jq -r '.keywords | join(",")' metadata.json)"

github_setup: sync-metadata github_ruleset_protect_master_create

# adds github ruleset to prevent --force and other destructive actions on the github main branch
github_ruleset_protect_master_create: github_ruleset_protect_master_delete
	gh api --method POST repos/$(just _github_repo)/rulesets --input - <<< '{{GITHUB_PROTECT_MASTER_RULESET}}'

# TODO this only supports deleting the single ruleset specified above
github_ruleset_protect_master_delete:
	repo=$(just _github_repo) && \
		ruleset_name=$(echo '{{GITHUB_PROTECT_MASTER_RULESET}}' | jq -r .name) && \
		ruleset_id=$(gh api repos/$repo/rulesets --jq ".[] | select(.name == \"$ruleset_name\") | .id") && \
		(([ -n "${ruleset_id}" ] || (echo "No ruleset found" && exit 0)) || gh api --method DELETE repos/$repo/rulesets/$ruleset_id)

_github_repo:
	gh repo view --json nameWithOwner -q .nameWithOwner
