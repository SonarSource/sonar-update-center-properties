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

For use with GitHub actions.

This will deploy in Prod account.

1. Open https://github.com/SonarSource/sonar-update-center-properties/actions/workflows/deploy.yml
2. Click Run workflow
