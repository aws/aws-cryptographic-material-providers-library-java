// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

plugins {
    `java-library`
    `maven-publish`
    // OS Detector for Optional ACCP
    id("com.google.osdetector") version "1.7.0"
}

group = "software.amazon.cryptography"
version = "1.0-SNAPSHOT"
description = "AwsCryptographyPrimitives"

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
//    sourceSets.create("amazonCorrettoCryptoProvider").java {
//        srcDir("src/main/java")
//        srcDir("src/main/dafny-generated")
//        srcDir("src/main/smithy-generated")
//        srcDir("src/accp/java")
//    }
    // Optional ACCP dependency for at least HKDF
    registerFeature("amazonCorrettoCryptoProvider") {
        // We may create a new source set with ACCP code...
        usingSourceSet(sourceSets["main"])
    }
}

repositories {
    mavenCentral()
    mavenLocal()
}

dependencies {
    implementation("org.dafny:DafnyRuntime:4.1.0")
    implementation("software.amazon.smithy.dafny:conversion:0.1")
    implementation("software.amazon.cryptography:StandardLibrary:1.0-SNAPSHOT")
    implementation("org.bouncycastle:bcprov-jdk18on:1.75")
    // "amazonCorrettoCryptoProviderImplementation"(
    implementation(
            "software.amazon.cryptools:AmazonCorrettoCryptoProvider:2.3.0:${determineClassifier()}")
}

publishing {
    publications.create<MavenPublication>("maven") {
        groupId = "software.amazon.cryptography"
        artifactId = "AwsCryptographyPrimitives"
        from(components["java"])
    }
    repositories { mavenLocal() }
}

tasks.withType<JavaCompile>() {
    options.encoding = "UTF-8"
}

tasks {
    register("runTests", JavaExec::class.java) {
        mainClass.set("TestsFromDafny")
        classpath = sourceSets["test"].runtimeClasspath
    }
}

// ACCP ONLY supports Linux and Mac
// https://github.com/corretto/amazon-corretto-crypto-provider/tree/main#compatibility--requirements
// But, they DO NOT release a Mac Version,
// they just call it linux.
fun determineClassifier(): String {
    if (osdetector.os.contains("osx")) {
        return "linux-" + osdetector.arch
    }
    return osdetector.classifier
}
