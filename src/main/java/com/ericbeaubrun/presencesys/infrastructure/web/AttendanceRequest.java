package com.ericbeaubrun.presencesys.infrastructure.web;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@Schema(description = "Payload emitted by the NFC reader client on each scan.")
public record AttendanceRequest(
        @NotBlank(message = "L'ID du lecteur ne peut pas être vide")
        @Size(min = 5, max = 5, message = "L'ID du lecteur doit faire exactement 5 caractères")
        @Schema(description = "Reader identifier, exactly 5 characters. The room id is derived from it.",
                example = "L1101")
        String readerId,

        @NotBlank(message = "L'ID de la carte ne peut pas être vide")
        @Size(min = 8, max = 8, message = "L'ID de la carte doit faire exactement 8 caractères")
        @Schema(description = "NFC card UID, exactly 8 characters.", example = "04A3B2C1")
        String cardId
) {}
