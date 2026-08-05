package com.ericbeaubrun.presencesys.infrastructure.web;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

/**
 * Corps de la requête pour créer ou modifier un pointage depuis l'interface admin.
 */
@Schema(description = "Payload used by the dashboard to create or update a record.")
public record AttendanceUpdateRequest(
        @NotBlank(message = "L'ID étudiant est obligatoire")
        @Schema(example = "E001")
        String studentId,

        @NotBlank(message = "L'ID cours est obligatoire")
        @Schema(example = "C001")
        String courseId,

        @NotBlank(message = "Le statut est obligatoire")
        @Pattern(regexp = "present|absent justifie", message = "Statut invalide")
        @Schema(description = "Only these two values are accepted.",
                allowableValues = {"present", "absent justifie"}, example = "present")
        String status,

        @Schema(description = "Arrival time as `HH:mm:ss`. Nullable.",
                example = "08:15:00", nullable = true)
        String arrivalTime,    // format HH:mm:ss, nullable

        @Schema(description = "Free-text justification. Nullable.",
                example = "Certificat médical", nullable = true)
        String justification   // nullable
) {}
