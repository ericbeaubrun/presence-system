package com.ericbeaubrun.presencesys.infrastructure.web;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.enums.SecuritySchemeType;
import io.swagger.v3.oas.annotations.info.Contact;
import io.swagger.v3.oas.annotations.info.Info;
import io.swagger.v3.oas.annotations.info.License;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.security.SecurityScheme;
import io.swagger.v3.oas.annotations.servers.Server;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.context.annotation.Configuration;

/**
 * Métadonnées de la spécification OpenAPI exposée sur /v3/api-docs.yaml.
 * Le site de documentation (docs/) est généré à partir de cette spécification.
 */
@Configuration
@OpenAPIDefinition(
        info = @Info(
                title = "Presence System API",
                version = "1.0.0",
                description = """
                        REST API of the **Attendance Management and Verification System** — an NFC-based \
                        attendance tracker built with Java 21 / Spring Boot, following a simplified \
                        hexagonal architecture.

                        The API exposes two families of endpoints:

                        * `/api/v1/attendances` — **public**, called by the Python NFC client running on the \
                        ACR122U reader. One call per badge scan.
                        * `/api/admin/**` — **protected**, requires HTTP Basic authentication with the \
                        `ADMIN` role. Used by the web administration dashboard for manual CRUD on \
                        attendance records.

                        ### Authentication

                        Admin endpoints use **HTTP Basic**. Send the `Authorization: Basic <base64(user:password)>` \
                        header on every request. CSRF is disabled and sessions are created on demand.

                        ### CORS

                        Only `http://localhost:*` and `http://127.0.0.1:*` origins are allowed, with credentials.
                        """,
                contact = @Contact(
                        name = "Eric Beaubrun",
                        url = "https://github.com/ericbeaubrun/presence-system"
                ),
                license = @License(
                        name = "See repository",
                        url = "https://github.com/ericbeaubrun/presence-system"
                )
        ),
        servers = @Server(
                url = "http://localhost:8080",
                description = "Local Docker Compose stack"
        ),
        tags = {
                @Tag(name = "Attendance", description = "Public endpoint used by the NFC reader client."),
                @Tag(name = "Admin", description = "Administration endpoints, `ADMIN` role required.")
        },
        security = @SecurityRequirement(name = "basicAuth")
)
@SecurityScheme(
        name = "basicAuth",
        type = SecuritySchemeType.HTTP,
        scheme = "basic",
        description = "HTTP Basic credentials of a user holding the `ADMIN` role."
)
public class OpenApiConfig {
}
