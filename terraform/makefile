# このmakefileでterraformコマンドを実行するには、事前にGoogle Cloud CLIをセットアップし、以下のコマンドを実行してください
# $ gcloud auth application-default login --project <使用するプロジェクトID>
# このコマンドにより生成されたGoogle Cloud CLIの認証情報(~/.config/gcloud/application_default_credentials.json)をコンテナー内にマウントして使用します

# note: /terraformディレクトリ内から/setupディレクトなどへのsymlinkがあるため、一個上の階層から-vオプションでマウントする必要がある
define tf
	docker run --init --rm -i $2 \
		-v $(CURDIR)/../:/work -w /work/terraform \
		-v ~/.config/gcloud:/root/.config/gcloud \
		hashicorp/terraform:latest \
		$1;
endef

.PHONY: init plan apply

init:
	$(call tf, -chdir=./example init)
plan:
	$(call tf, -chdir=./example plan)
apply:
	$(call tf, -chdir=./example apply)
