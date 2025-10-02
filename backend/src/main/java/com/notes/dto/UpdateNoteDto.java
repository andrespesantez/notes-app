package com.notes.dto;

import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class UpdateNoteDto {
    @Size(max = 255)
    private String title;

    private String content;

    private String category;

    private Boolean published;
}
