package org.sonarsource.updatecenter;

import org.assertj.core.api.SoftAssertions;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.sonar.updatecenter.common.UpdateCenterDeserializer;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.*;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import static java.util.Optional.ofNullable;
import static org.assertj.core.api.Assertions.assertThatCode;

class MetadataTest {
    private static final String GLOBAL_PROPERTIES_FILE = "update-center-source.properties";
    private static final File BASE_DIR = new File(".");

    private static final List<String> propertiesFilesToIgnore = List.of(
            "edition-templates.properties",
            GLOBAL_PROPERTIES_FILE
    );
    private static Set<String> REGISTERED_PLUGIN_KEYS;
    private static Set<String> CONFIGURED_PLUGIN_KEYS;

    private static Map<String, Properties> PLUGINS_PROPERTIES;

    @BeforeAll
    static void globalInit() {
        PLUGINS_PROPERTIES = ofNullable(BASE_DIR.listFiles((d, name) ->
                name.endsWith(".properties") && !propertiesFilesToIgnore.contains(name)
        ))
                .map(List::of)
                .orElseThrow(() -> new IllegalStateException("Unable to find any metadata file in project root: " + BASE_DIR.getAbsolutePath()))
                .stream()
                .collect(Collectors.toMap(
                        f -> f.getName().replaceFirst("\\.properties$", ""),
                        MetadataTest::toProperties
                ));


        CONFIGURED_PLUGIN_KEYS = PLUGINS_PROPERTIES.keySet();

        final Properties globalProperties = toProperties(new File(BASE_DIR, GLOBAL_PROPERTIES_FILE));
        final Set<String> registeredPluginKeys = new HashSet<>();
        registeredPluginKeys.addAll(List.of(globalProperties.getProperty("plugins", "").split(",")));
        registeredPluginKeys.addAll(List.of(globalProperties.getProperty("scanners", "").split(",")));
        REGISTERED_PLUGIN_KEYS = Collections.unmodifiableSet(registeredPluginKeys);

    }

    private static Properties toProperties(File file) {
        Properties result = new Properties();
        try (InputStream inputStream = new FileInputStream(file)) {
            result.load(inputStream);
        } catch (IOException e) {
            throw new IllegalArgumentException("Unable to read properties file", e);
        }
        return result;
    }

    @Test
    @DisplayName("All registered plugins should be configured")
    void all_registered_plugins_should_be_configured() {
        List<String> configuredPluginsNotRegistered = CONFIGURED_PLUGIN_KEYS.stream()
                .filter(existingPlugin -> !REGISTERED_PLUGIN_KEYS.contains(existingPlugin))
                .collect(Collectors.toList());

        List<String> nonexistentRegisteredPlugin = REGISTERED_PLUGIN_KEYS.stream()
                .filter(declaredPlugin -> !CONFIGURED_PLUGIN_KEYS.contains(declaredPlugin))
                .collect(Collectors.toList());

        final SoftAssertions assertions = new SoftAssertions();
        assertions
                .assertThat(nonexistentRegisteredPlugin)
                .describedAs("All registered plugins must have corresponding property file (named: {pluginname}.properties")
                .isEmpty();
        assertions.assertAll();
    }

    @Test
    @DisplayName("All configured plugins should be registered")
    @Disabled("'cayc' defined plugin in 'cayc.properties' is not declared in 'update-center-source.properties'. Should this file be deleted?")
    void all_configured_plugins_should_be_regitered() {
        List<String> configuredPluginsNotRegistered = CONFIGURED_PLUGIN_KEYS.stream()
                .filter(existingPlugin -> !REGISTERED_PLUGIN_KEYS.contains(existingPlugin))
                .collect(Collectors.toList());

        List<String> nonexistentRegisteredPlugin = REGISTERED_PLUGIN_KEYS.stream()
                .filter(declaredPlugin -> !CONFIGURED_PLUGIN_KEYS.contains(declaredPlugin))
                .collect(Collectors.toList());

        final SoftAssertions assertions = new SoftAssertions();
        assertions
                .assertThat(configuredPluginsNotRegistered)
                .describedAs("All configured plugins must be registered in " + GLOBAL_PROPERTIES_FILE)
                .isEmpty();
        assertions.assertAll();
    }

    /*
        From: https://community.sonarsource.com/t/deploying-to-the-marketplace/35236d
        The key of your plugin must be:
        - short and unique
        - lowercase (no camelcase)
        - composed only of [a-z0-9]
        - related to the name of your plugin
        - not just the name of a language (e.g. cannot be java, rust, js/javascript, …)
    */
    @Test
    @DisplayName("All plugin keys must meet the requirements")
    void plugin_key_must_meet_the_requirements() {
        final Pattern pluginKeyPattern = Pattern.compile("^[a-z0-9]+$");
        final SoftAssertions assertions = new SoftAssertions();
        PLUGINS_PROPERTIES.keySet().forEach(
                pluginKey -> {
                    assertions
                            .assertThat(pluginKey)
                            .describedAs("The key of plugin '" + pluginKey + "' must be short")
                            .hasSizeLessThan(30);
                    assertions
                            .assertThat(pluginKey)
                            .describedAs("The key of plugin '" + pluginKey + "' must be composed only of [a-z0-9]")
                            .matches(pluginKeyPattern);
                }
        );
        assertions.assertAll();
    }

    /*
        From: https://github.com/SonarSource/sonar-update-center-properties/blob/master/README.md
        - artifactId must match : sonar-{pluginKey}-plugin
    */
    @Test
    @DisplayName("artifactId must match: sonar-{pluginKey}-plugin")
    @Disabled("This requirement does not seem relevant to test because there is too much non-compliance in the existing system.")
    void artifactId_must_match_plugin_key() {
        final Pattern pluginKeyPattern = Pattern.compile("^[a-z0-9]+$");
        final SoftAssertions assertions = new SoftAssertions();
        PLUGINS_PROPERTIES.keySet().forEach(pluginKey -> {
                    String artifactId = PLUGINS_PROPERTIES.get(pluginKey).getProperty("defaults.mavenArtifactId");
                    assertions
                            .assertThat(artifactId)
                            .describedAs("artifactId '" + artifactId + "' must match to: 'sonar-" + pluginKey + "-plugin' for plugin: " + pluginKey)
                            .matches(Pattern.compile("^sonar-" + Pattern.quote(pluginKey) + "-plugin$"));
                }
        );
        assertions.assertAll();
    }

    @Test
    @DisplayName("All UpdateCenter properties should be correct")
    void all_updatecenter_properties_should_be_correct() throws IOException {
        assertThatCode(() ->
                new UpdateCenterDeserializer(UpdateCenterDeserializer.Mode.DEV, false, false)
                        .fromManyFiles(new File(BASE_DIR, GLOBAL_PROPERTIES_FILE)))
                .doesNotThrowAnyException();
    }
}
