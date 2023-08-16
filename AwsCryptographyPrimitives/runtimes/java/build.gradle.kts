// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
import org.gradle.api.tasks.testing.logging.TestExceptionFormat
import org.gradle.api.tasks.testing.logging.TestLogEvent

val accpLocalJar: String by project

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
        srcDir("src/test/accp")
    }
    sourceSets.create("accp").java {
        srcDir("src/main/java")
        srcDir("src/main/dafny-generated")
        srcDir("src/main/smithy-generated")
        srcDir("src/main/accp")
    }
    // Optional ACCP dependency for at least HKDF
    registerFeature("accp") {
        // We may create a new source set with ACCP code...
        usingSourceSet(sourceSets["accp"])
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
    "accpImplementation"("org.dafny:DafnyRuntime:4.1.0")
    "accpImplementation"("software.amazon.smithy.dafny:conversion:0.1")
    "accpImplementation"("software.amazon.cryptography:StandardLibrary:1.0-SNAPSHOT")
    "accpImplementation"("org.bouncycastle:bcprov-jdk18on:1.75")
    // ACCP ONLY supports Linux, otherwise you have to build it from source and provide it
    // https://github.com/corretto/amazon-corretto-crypto-provider/tree/main#compatibility--requirements
    if (project.hasProperty("accpLocalJar")) {
        logger.warn("Using ACCP Local Jar.")
        "accpImplementation"(files(accpLocalJar))
        testImplementation(files(accpLocalJar))
    } else if (osdetector.os.contains("linux")) {
        logger.warn("Using ACCP Linux from Maven with Suffix {}.", osdetector.classifier)
        "accpImplementation"(
            "software.amazon.cryptools:AmazonCorrettoCryptoProvider:2.3.0:${osdetector.classifier}")
        testImplementation(
            "software.amazon.cryptools:AmazonCorrettoCryptoProvider:2.3.0:${osdetector.classifier}")
    } else {
        logger.warn("NOT using ACCP.")
        // logger.warn("Using un-supported ACCP.")
        // "accpImplementation"(
        //    "software.amazon.cryptools:AmazonCorrettoCryptoProvider:2.3.0:${overrideClassifier()}")
        // testImplementation(
        //    "software.amazon.cryptools:AmazonCorrettoCryptoProvider:2.3.0:${overrideClassifier()}")
    }
    // https://mvnrepository.com/artifact/org.testng/testng
    testImplementation("org.testng:testng:7.5")
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

fun overrideClassifier(): String {
    if (osdetector.os.contains("osx")) {
       logger.warn("Overriding detected os `osx` to be `linux`.")
       return "linux-" + osdetector.arch
    }
    return osdetector.classifier
}

tasks.test {
    useTestNG() {

    }
    // This will show System.out.println statements
    testLogging.showStandardStreams = true

    testLogging {
        lifecycle {
            events = mutableSetOf(TestLogEvent.FAILED, TestLogEvent.SKIPPED)
            exceptionFormat = TestExceptionFormat.FULL
            showExceptions = true
            showCauses = true
            showStackTraces = true
            showStandardStreams = true
        }
        info.events = lifecycle.events
        info.exceptionFormat = lifecycle.exceptionFormat
    }

    // See https://github.com/gradle/kotlin-dsl/issues/836
    addTestListener(object : TestListener {
        override fun beforeSuite(suite: TestDescriptor) {}
        override fun beforeTest(testDescriptor: TestDescriptor) {}
        override fun afterTest(testDescriptor: TestDescriptor, result: TestResult) {}

        override fun afterSuite(suite: TestDescriptor, result: TestResult) {
            if (suite.parent == null) { // root suite
                logger.lifecycle("----")
                logger.lifecycle("Test result: ${result.resultType}")
                logger.lifecycle("Test summary: ${result.testCount} tests, " +
                        "${result.successfulTestCount} succeeded, " +
                        "${result.failedTestCount} failed, " +
                        "${result.skippedTestCount} skipped")
            }
        }
    })
}
