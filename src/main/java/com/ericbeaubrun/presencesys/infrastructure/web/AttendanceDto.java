package com.ericbeaubrun.presencesys.infrastructure.web;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Attendance record enriched with student, course and room details.")
public record AttendanceDto(
        @Schema(example = "E001") String studentId,
        @Schema(example = "Eric Beaubrun") String studentFullName,
        @Schema(example = "C001") String courseId,
        @Schema(example = "2026-08-05") String courseDate,
        @Schema(example = "08:00:00") String courseStartTime,
        @Schema(example = "10:00:00") String courseEndTime,
        @Schema(example = "S1101") String roomId,
        @Schema(example = "present") String status,
        @Schema(example = "08:15:00", nullable = true) String arrivalTime,
        @Schema(nullable = true) String justification
) {}
