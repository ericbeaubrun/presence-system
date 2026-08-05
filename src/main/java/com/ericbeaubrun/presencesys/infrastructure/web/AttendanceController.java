package com.ericbeaubrun.presencesys.infrastructure.web;

import com.ericbeaubrun.presencesys.domain.service.AttendanceService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/attendances")
@RequiredArgsConstructor
@Tag(name = "Attendance")
public class AttendanceController {

    private final AttendanceService attendanceService;

    @Operation(
            summary = "Register an attendance from an NFC card scan",
            description = """
                    Called by the hardware client when a card is presented to the reader.

                    The server resolves the student from the card UID, derives the room from the \
                    reader id (`L` prefix is replaced by `S`), looks up the course currently running \
                    in that room, and records a `present` attendance with the current time.

                    The request is rejected when the card is unknown, when no course is scheduled in \
                    that room at that moment, or when the student already checked in for that course.
                    """,
            security = {}
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "Attendance registered.",
                    content = @Content(
                            mediaType = "text/plain",
                            schema = @Schema(type = "string"),
                            examples = @ExampleObject(
                                    value = "Présence enregistrée avec succès pour l'étudiant E001 au cours C001")
                    )
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = """
                            Business rule violation or validation error. The body carries the reason: \
                            unknown card, no course scheduled in the room right now, or duplicate check-in.
                            """,
                    content = @Content(
                            mediaType = "text/plain",
                            schema = @Schema(type = "string"),
                            examples = {
                                    @ExampleObject(
                                            name = "unknownCard",
                                            value = "Aucun étudiant trouvé avec la carte NFC : 04A3B2C1"),
                                    @ExampleObject(
                                            name = "noCourse",
                                            value = "Aucun cours n'est programmé dans cette salle en ce moment."),
                                    @ExampleObject(
                                            name = "duplicate",
                                            value = "L'étudiant a déjà été enregistré (présent) pour ce cours.")
                            }
                    )
            ),
            @ApiResponse(
                    responseCode = "500",
                    description = "Unexpected server error.",
                    content = @Content(
                            mediaType = "text/plain",
                            schema = @Schema(type = "string"),
                            examples = @ExampleObject(value = "Erreur serveur : ...")
                    )
            )
    })
    @PostMapping
    public ResponseEntity<String> scanCard(@Valid @RequestBody AttendanceRequest request) {
        try {
            String message = attendanceService.registerAttendance(request.cardId(), request.readerId());
            return ResponseEntity.ok(message);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Erreur serveur : " + e.getMessage());
        }
    }
}
