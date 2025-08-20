# sonar-update-center Update

## Staging

This is for local usage.

### Requirements

- direnv https://direnv.net/
- Maven Developer
  setup [xtranet/DEV/Developer+Box#Maven-Settings](https://xtranet-sonarsource.atlassian.net/wiki/spaces/DEV/pages/776711/Developer+Box#Maven-Settings)
- Access to `SonarSource-Staging` AWS account `RECDNElevatedStaging` role

### Usage

```shell
cd po-generate-update-center-prod
direnv allow
aws sso login --sso-session sonar
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
