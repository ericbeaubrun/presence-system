# Attendance Management and Verification System

## Overview

The Attendance Management and Verification System is a complete solution for managing student or employee attendance using NFC smart cards. The system combines a secure Spring Boot backend, a web-based administration interface, and a lightweight Python client connected to an ACR122U NFC reader.

---

## System Architecture

The application consists of three main components:

### 1. Backend Server

Built with **Java 21** and **Spring Boot 4.1.0**, following a simplified **Hexagonal Architecture**.

Its responsibilities include:

* Processing attendance timestamps
* Cross-checking room schedules
* Preventing duplicate check-ins
* Exposing secure REST APIs
* Protecting administrative endpoints using **Spring Security** with **HTTP Basic Authentication**

### 2. Web Administration Interface

A web dashboard communicating asynchronously with the backend REST API.

Features include:

* Create attendance records
* Read attendance history
* Update records
* Delete records
* Manual attendance management for administrators

### 3. Hardware Client

A lightweight **Python** application running on a terminal connected to an **ACR122U NFC reader**.

Responsibilities:

* Read NFC card UIDs
* Build JSON payloads
* Send attendance events to the backend server

---

# Technical Stack

## Backend

| Category              | Technology             |
| --------------------- | ---------------------- |
| Language              | Java 21                |
| Framework             | Spring Boot 4.1.0      |
| Architecture          | Hexagonal Architecture |
| Security              | Spring Security        |
| Database              | PostgreSQL             |
| ORM                   | Spring Data JPA        |
| Migration             | Flyway                 |
| Validation            | Jakarta Validation     |
| Boilerplate Reduction | Lombok                 |
| Build Tool            | Gradle                 |

### Gradle Dependencies

* `spring-boot-starter-webmvc`
* `spring-boot-starter-security`
* `spring-boot-starter-data-jpa`
* `postgresql`
* `spring-boot-starter-flyway`
* `flyway-database-postgresql`
* `spring-boot-starter-validation`
* `lombok`

---

## Hardware Client

### Runtime

* Python 3.x

### Libraries

* `pyscard`
* `requests`

---

# Testing Suite

All testing utilities are located inside:

```text
src/tests/
```

## admin_test.html

Browser-based testing interface used to:

* Verify CORS configuration
* Test secured REST endpoints
* Execute CRUD operations through the Fetch API

---

## nfc_reader_client_test.py

Hardware integration test that:

* Reads NFC cards using the ACR122U reader
* Retrieves the card UID
* Sends the generated JSON payload to the backend server

---

## postman_test.json

Postman collection used for API testing.

Expected responses include:

| Scenario           | Expected Status |
| ------------------ | --------------- |
| Valid check-in     | 200 OK          |
| Duplicate check-in | 400 Bad Request |
| Unknown badge      | 400 Bad Request |
| Schedule mismatch  | 400 Bad Request |

---

# Installation

## 1. Build the Project

Generate the executable JAR:

```bash
./gradlew clean bootJar
```

---

## 2. Start Docker Services

Build and launch the application stack:

```bash
docker compose up -d --build
```

Default services:

* Backend API: **http://localhost:8080**
* PostgreSQL: **localhost:1234**

---

## 3. Test the NFC Hardware Client

Install the required Python packages:

```bash
pip install requests pyscard
```

Run the test script:

```bash
python src/tests/nfc_reader_client_test.py
```

---

## 4. Run the Web Administration Tests

Start a local HTTP server:

```bash
python -m http.server 3000
```

Then open your browser and navigate to:

```
http://localhost:3000/src/tests/admin_test.html
```

---

# Requirements

* Java 21
* Gradle
* Docker & Docker Compose
* Python 3.x
* PostgreSQL
* ACR122U NFC Reader

