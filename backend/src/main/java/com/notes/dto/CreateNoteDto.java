package com.notes.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class CreateNoteDto {
    @NotBlank(message = "Title is mandatory")
    @Size(max = 255)
    private String title;

    private String content;

    @NotBlank(message = "Category is mandatory")
    private String category;

    private boolean published;
}
