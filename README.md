# Sonar Update Center Properties

This allows you to deploy a plugin to the [SonarQube Marketplace](https://docs.sonarqube.org/latest/instance-administration/marketplace/).

[Read here for more information](https://community.sonarsource.com/t/deploying-to-the-marketplace/35236).


## How to fill in your plugin's property file

### Initial creation

#### Create file

In https://github.com/SonarSource/sonar-update-center-properties

File name should correspond to plugin's `pluginKey` and end with a `.properties` extension. Plugin key is set in the plugin module's pom (not the top-level pom):

* Explicitly in a `sonar.pluginKey` property. This is the first choice / preferred
* Implicitly by the artifactId:
  * `sonar-{pluginKey}-plugin`
  * when the `sonar-x-plugin` pattern is not used for the artifactId, the plugin key will be the whole artifact id.

#### Populate file

Provide the following meta values:

* `category` - one of: Coverage, Developer Tools, External Analyzers, Governance, Integration, Languages, Localization, Visualization/Reporting
* `description`
* `homepageUrl`
* `archivedVersions` =[ leave this blank for now ]
* `publicVersions` =[versionId]
* `defaults.mavenGroupId` =[the Maven `groupId` ]
* `defaults.mavenArtifactId` =[value of the top-level `artifactId` ]

For the initially listed version create the following block:

* `[versionId].description` =[free text. Spaces allowed. No quoting required]
* `[versionId].sqVersions` =[compatibility information. See 'Filling in sqVersions compatibility ranges' below]
* `[versionId].date` =[release date with format: YYYY-MM-DD]
* `[versionId].changelogUrl` =
* `[versionId].downloadUrl` =

The full list of meta information that can be provided (potentially overriding pom file values) can be found on [GitHub](https://github.com/SonarSource/sonar-update-center/blob/master/sonar-update-center-common/src/main/java/org/sonar/updatecenter/common/Plugin.java#L154).

#### Register file

Add file name (without `.properties` extension) to `plugins` value in https://github.com/SonarSource/sonar-update-center-properties/blob/master/update-center-source.properties

### Updating for new releases

Create a new block in the file with this format:

* `[versionId].description` =[free text. Spaces allowed. No quoting required]
* `[versionId].sqVersions` =[compatibility information. See 'Filling in sqVersions compatibility ranges' below]
* `[versionId].date` =[release date with format: YYYY-MM-DD]
* `[versionId].changelogUrl` =
* `[versionId].downloadUrl` =

Add `[versionId]` to the `publicVersions` list. Move to `archivedVersions` any versions with identical compatibility. See also 'Filling in sqVersions, publicVersions, and archivedVersions' below

### Filling in `sqVersions` , `publicVersions` and `archivedVersions`

The global field `publicVersions` is a comma-delimited list of plugin versions which should be offered to the user in the Marketplace and listed in the Plugin Version Matrix.

* Compatibility of Public versions cannot overlap
* Multiple versions can be in publicVersions if the versions of SonarQube they are compatible with do not overlap.

The global field `archivedVersions` is a comma-delimited list of no-longer-preferred plugin versions. If a user has an archived version of a plugin installed, the Marketplace will offer an upgrade to the relevant public version. Upgrades will not be offered for plugin versions which are not found in `archivedVersions` .

* Compatibility of Archived versions can overlap
* If new version and previous version are compatible with the same versions of SonarQube, move the previous version into `archivedVersions` .

The `sqVersions` field of a release block gives the versions of SonarQube with which the plugin version is compatible. 

* Compatibility can be with a range, with a single version, or with a list of versions / ranges
* Compatibility is generally listed as a range in the form of [start,end]
* The value of start should be a SonarQube version number.
* The value used for end may either be a version number or the special string `LATEST` .
* Only one version of a plugin can be compatible with `LATEST` , and it must be the most recent release
* Compatibility of public versions cannot overlap, so if necessary edit the range end for the older version to stop just before the newer version's compatibility starts.
* You can use a wildcard at the end of a range, but not at the beginning.
  * :white_check_mark:  `[7.9,7.9.*]`
  * :no_entry_sign: `[7.9.*,LATEST]`
* Multiple entries in a compatibility list should be comma-delimited, E.G. `5.5,[6.7,6.7.*],[7.3,LATEST]`

### Moving a version from `publicVersions` to `archivedVersions`
The Marketplace offers/prompts users to upgrade from one plugin version to another based on the compatibility ranges listed in the metadata files in this repo. To make sure all your users are offered your latest upgrade, you need to make sure the previous plugin version's compatibility range ends with whatever version of SonarQube was current at the time of your release. 

So if the old plugin version was compatible with `LATEST`, replace that value with the current SonarQube release version, potentially ending with a wildcard for a point version. For instance, let's say we need to archive plugin version 1.4, and the current SonarQube version is 9.8.3:

**From**
`1.4.sqVersions=[8.9,LATEST]`

**To**
`1.4.sqVersions=[8.9,9.8.*]`

Using a wildcard in the end of the range future-proofs you against any subsequent point releases of the current version.

### Compatibility with versions older than the current LTS
New plugin versions should not be marked for compatibility with SonarQube versions older than the current LTS. 
