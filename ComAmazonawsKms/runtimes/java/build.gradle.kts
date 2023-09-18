// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

plugins {
    `java-library`
    `maven-publish`
}

group = "software.amazon.cryptography"
version = "1.0-SNAPSHOT"
description = "ComAmazonawsKms"

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
    implementation("org.dafny:DafnyRuntime:4.2.0")
    implementation("software.amazon.smithy.dafny:conversion:0.1")
    implementation("software.amazon.cryptography:StandardLibrary:1.0-SNAPSHOT")
    implementation(platform("software.amazon.awssdk:bom:2.19.1"))
    implementation("software.amazon.awssdk:kms")
}

publishing {
    publications.create<MavenPublication>("maven") {
        groupId = "software.amazon.cryptography"
        artifactId = "ComAmazonawsKms"
        from(components["java"])
    }
    repositories { mavenLocal() }
}

tasks.withType<JavaCompile>() {
    options.encoding = "UTF-8"
}

tasks.withType<Wrapper>() {
    gradleVersion = "7.6"
}

tasks {
    register("runTests", JavaExec::class.java) {
        mainClass.set("TestsFromDafny")
        classpath = sourceSets["test"].runtimeClasspath
    }
}
