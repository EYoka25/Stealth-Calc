import com.github.jengelman.gradle.plugins.shadow.tasks.ShadowJar
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    kotlin("jvm")
    kotlin("plugin.serialization")
    id("com.github.johnrengelman.shadow") version "8.1.1"
    application
}

group = "com.opencalc"
version = "1.0.0"

java {
    sourceCompatibility = JavaVersion.VERSION_21
    targetCompatibility = JavaVersion.VERSION_21
}



dependencies {
    // Ktor Server Core
    implementation("io.ktor:ktor-server-core:3.0.0")
    implementation("io.ktor:ktor-server-netty:3.0.0")
    implementation("io.ktor:ktor-server-websockets:3.0.0")
    implementation("io.ktor:ktor-server-content-negotiation:3.0.0")
    implementation("io.ktor:ktor-server-cors:3.0.0")
    implementation("io.ktor:ktor-serialization-kotlinx-json:3.0.0")

    // Security & Hashing (Fixes the mindrot/BCrypt errors)
    implementation("org.mindrot:jbcrypt:0.4")

    // Database - Exposed ORM + PostgreSQL
    implementation("org.jetbrains.exposed:exposed-core:0.52.0")
    implementation("org.jetbrains.exposed:exposed-dao:0.52.0")
    implementation("org.jetbrains.exposed:exposed-jdbc:0.52.0")
    implementation("org.jetbrains.exposed:exposed-java-time:0.52.0")
    implementation("org.postgresql:postgresql:42.7.3")
    implementation("org.xerial:sqlite-jdbc:3.47.0.0")
    implementation("com.zaxxer:HikariCP:5.1.0")



    // MinIO S3
    implementation("io.minio:minio:8.5.11")

    // Logging
    implementation("ch.qos.logback:logback-classic:1.5.6")

    // Testing
    testImplementation("io.ktor:ktor-server-test-host:3.0.0")
    testImplementation("org.jetbrains.kotlin:kotlin-test:2.0.0")
}

tasks.withType<KotlinCompile>().configureEach {
    kotlinOptions {
        jvmTarget = "21"
    }
}

tasks.withType<ShadowJar> {
    manifest {
        attributes["Main-Class"] = "com.opencalc.backend.ApplicationKt"
    }
    archiveClassifier.set("all")
    mergeServiceFiles()
}

application {
    mainClass.set("com.opencalc.backend.ApplicationKt")
}

tasks.withType<JavaCompile> {
    enabled = false
}