load("github.com/SonarSource/cirrus-modules@v2", "load_features")
load("cirrus", "env", "fs", "yaml")


def main(ctx):
    if env.get("CIRRUS_BRANCH") == env.get("CIRRUS_DEFAULT_BRANCH"):
        return yaml.dumps(load_features(ctx, only_if=dict())) + fs.read(".cirrus-private.yml")
    else:
        return fs.read(".cirrus-public.yml")
