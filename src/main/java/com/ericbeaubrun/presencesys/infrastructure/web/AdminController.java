package com.ericbeaubrun.presencesys.infrastructure.web;

import com.ericbeaubrun.presencesys.domain.service.AdminAttendanceService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * Contrôleur REST réservé aux administrateurs.
 * Toutes les routes sont sous /api/admin/** et protégées par Spring Security (rôle ADMIN).
 */
@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
@Tag(name = "Admin")
@ApiResponses({
        @ApiResponse(responseCode = "401", description = "Missing or invalid credentials.", content = @Content),
        @ApiResponse(responseCode = "403", description = "Authenticated, but the user is not an `ADMIN`.", content = @Content)
})
public class AdminController {

    private final AdminAttendanceService adminAttendanceService;

    /**
     * Vérifie que les credentials sont valides et retourne les infos de l'utilisateur connecté.
     * Utilisé par le front JS pour valider la session au login.
     */
    @Operation(
            summary = "Return the authenticated administrator",
            description = """
                    Validates the supplied credentials and echoes back the identity of the caller. \
                    The dashboard uses it as a login check.
                    """
    )
    @ApiResponse(
            responseCode = "200",
            description = "Credentials are valid.",
            content = @Content(
                    mediaType = "application/json",
                    examples = @ExampleObject(value = """
                            {"username": "admin", "role": "ROLE_ADMIN"}""")
            )
    )
    @GetMapping("/me")
    public ResponseEntity<Map<String, String>> me(Authentication auth) {
        return ResponseEntity.ok(Map.of(
                "username", auth.getName(),
                "role", auth.getAuthorities().iterator().next().getAuthority()
        ));
    }

    /**
     * Retourne la liste complète de tous les pointages avec les détails enrichis.
     */
    @Operation(
            summary = "List every attendance record",
            description = "Returns the full attendance history, enriched with student, course and room details."
    )
    @ApiResponse(
            responseCode = "200",
            description = "Attendance list.",
            content = @Content(
                    mediaType = "application/json",
                    array = @ArraySchema(schema = @Schema(implementation = AttendanceDto.class))
            )
    )
    @GetMapping("/attendances")
    public ResponseEntity<List<AttendanceDto>> getAllAttendances() {
        return ResponseEntity.ok(adminAttendanceService.getAllAttendances());
    }

    /**
     * Crée un nouveau pointage manuel.
     */
    @Operation(summary = "Create an attendance record manually")
    @ApiResponses({
            @ApiResponse(
                    responseCode = "201",
                    description = "Record created.",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = AttendanceDto.class))
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Validation failed, or the student / course does not exist.",
                    content = @Content
            )
    })
    @PostMapping("/attendances")
    public ResponseEntity<AttendanceDto> createAttendance(
            @Valid @RequestBody AttendanceUpdateRequest request) {
        try {
            AttendanceDto created = adminAttendanceService.createAttendance(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(created);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Met à jour le statut / heure / justificatif d'un pointage existant.
     */
    @Operation(
            summary = "Update an existing attendance record",
            description = """
                    The record is identified by the `studentId` + `courseId` pair carried in the body. \
                    Status, arrival time and justification are overwritten.
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "Record updated.",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = AttendanceDto.class))
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "No record matches the given `studentId` / `courseId`.",
                    content = @Content
            )
    })
    @PutMapping("/attendances")
    public ResponseEntity<AttendanceDto> updateAttendance(
            @Valid @RequestBody AttendanceUpdateRequest request) {
        try {
            AttendanceDto updated = adminAttendanceService.updateAttendance(request);
            return ResponseEntity.ok(updated);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * Supprime un pointage identifié par studentId et courseId (passés en query params).
     */
    @Operation(summary = "Delete an attendance record")
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "Record deleted.",
                    content = @Content(
                            mediaType = "application/json",
                            examples = @ExampleObject(value = """
                                    {"message": "Pointage supprimé avec succès."}"""))
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "No record matches the given `studentId` / `courseId`.",
                    content = @Content(mediaType = "application/json")
            )
    })
    @DeleteMapping("/attendances")
    public ResponseEntity<Map<String, String>> deleteAttendance(
            @Parameter(description = "Student identifier.", example = "E001")
            @RequestParam String studentId,
            @Parameter(description = "Course identifier.", example = "C001")
            @RequestParam String courseId) {
        try {
            adminAttendanceService.deleteAttendance(studentId, courseId);
            return ResponseEntity.ok(Map.of("message", "Pointage supprimé avec succès."));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("error", e.getMessage()));
        }
    }
}
