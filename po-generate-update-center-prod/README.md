# sonar-update-center Update

## Staging

This is for local usage.

### Requirements

- direnv https://direnv.net/
- Vault CLI https://www.vaultproject.io/downloads
- Vault setup
  [xtranet/RE/HashiCorp+Vault#Generate-TOTP-URIs-(admin)](https://xtranet-sonarsource.atlassian.net/wiki/spaces/RE/pages/2466316312/HashiCorp+Vault#Generate-TOTP-URIs-(admin))
- JQ (Stedolan) https://stedolan.github.io/jq/download/
- Maven Developer
  setup [xtranet/DEV/Developer+Box#Maven-Settings](https://xtranet-sonarsource.atlassian.net/wiki/spaces/DEV/pages/776711/Developer+Box#Maven-Settings)

### Usage

```shell
cd po-generate-update-center-prod
vault-login-staging
direnv allow
```

The environment will now be provisioned to work with Staging account.

```shell
bash -i << 'EOF'
source generate.sh
source prepare_transfer_dir.sh
./upload.sh --dryrun
EOF
```

## Production

For use with Cirrus CI.

This will deploy in Prod account.

1. Open https://cirrus-ci.com/github/SonarSource/sonar-update-center-properties/master
2. Browse in the more recent build to the `po-generate-update-center-prod` task
3. Click on the Trigger button
