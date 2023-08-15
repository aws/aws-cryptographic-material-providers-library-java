// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
import java.net.URI
import javax.annotation.Nullable

val publishedVersion: String by project

plugins {
    `java-library`
    `maven-publish`
}

group = "software.amazon.cryptography"
version = "1.0-SNAPSHOT"
description = "TestAwsCryptographicMaterialProviders"

java {
    toolchain.languageVersion.set(JavaLanguageVersion.of(8))
    sourceSets["main"].java {
        srcDir("src/main/java")
        srcDir("src/main/dafny-generated")
        srcDir("src/main/smithy-generated")
    }
    sourceSets["test"].java {
        srcDir("src/test/dafny-generated")
    }
}

repositories {
    mavenCentral()
    mavenLocal()
}

dependencies {
    implementation("org.dafny:DafnyRuntime:4.1.0")
    implementation("software.amazon.smithy.dafny:conversion:0.1")
    implementation("software.amazon.cryptography:aws-cryptographic-material-providers:${
        if (project.hasProperty("publishedVersion")) publishedVersion else "1.0-SNAPSHOT"}")
    implementation(platform("software.amazon.awssdk:bom:2.19.1"))
    implementation("software.amazon.awssdk:dynamodb")
    implementation("software.amazon.awssdk:dynamodb-enhanced")
    implementation("software.amazon.awssdk:kms")
    implementation("software.amazon.awssdk:core:2.19.1")
}

publishing {
    publications.create<MavenPublication>("maven") {
        groupId = group as String?
        artifactId = description
        from(components["java"])
    }
    repositories { mavenLocal() }
}

tasks.withType<JavaCompile>() {
    options.encoding = "UTF-8"
}

tasks.register<JavaExec>("runTests") {
    dependsOn("copyKeysJSON")
    mainClass.set("TestsFromDafny")
    classpath = sourceSets["test"].runtimeClasspath
}

tasks.register<Copy>("copyKeysJSON") {
    from(layout.projectDirectory.file("../../dafny/TestVectorsAwsCryptographicMaterialProviders/test/keys.json"))
    into(layout.projectDirectory.dir("dafny/TestVectorsAwsCryptographicMaterialProviders/test"))
}

tasks.wrapper {
    gradleVersion = "7.6"
}
