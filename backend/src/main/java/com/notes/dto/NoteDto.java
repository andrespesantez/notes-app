package com.notes.dto;

import java.time.LocalDateTime;

import lombok.Data;

@Data
public class NoteDto {
    private Long id;
    private String title;
    private String content;
    private String category;
    private boolean published;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
