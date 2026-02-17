install:
	gh extension install .

sync-metadata:
	gh repo edit \
		--description "$(jq -r '.description' metadata.json)" \
		--homepage "$(jq -r '.homepage' metadata.json)" \
		--add-topic "$(jq -r '.keywords | join(",")' metadata.json)"
