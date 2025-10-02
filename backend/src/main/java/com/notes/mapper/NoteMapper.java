package com.notes.mapper;

import com.notes.dto.CreateNoteDto;
import com.notes.dto.NoteDto;
import com.notes.dto.UpdateNoteDto;
import com.notes.model.Note;
import org.springframework.stereotype.Component;

@Component
public class NoteMapper {

    public NoteDto toDto(Note note) {
        if (note == null) {
            return null;
        }
        NoteDto dto = new NoteDto();
        dto.setId(note.getId());
        dto.setTitle(note.getTitle());
        dto.setContent(note.getContent());
        dto.setCategory(note.getCategory());
        dto.setPublished(note.isPublished());
        dto.setCreatedAt(note.getCreatedAt());
        dto.setUpdatedAt(note.getUpdatedAt());
        return dto;
    }

    public Note toEntity(CreateNoteDto dto) {
        if (dto == null) {
            return null;
        }
        Note note = new Note();
        note.setTitle(dto.getTitle());
        note.setContent(dto.getContent());
        note.setCategory(dto.getCategory());
        note.setPublished(dto.isPublished());
        return note;
    }

    public void updateEntityFromDto(UpdateNoteDto dto, Note entity) {
        if (dto == null || entity == null) {
            return;
        }
        if (dto.getTitle() != null) {
            entity.setTitle(dto.getTitle());
        }
        if (dto.getContent() != null) {
            entity.setContent(dto.getContent());
        }
        if (dto.getCategory() != null) {
            entity.setCategory(dto.getCategory());
        }
        if (dto.getPublished() != null) {
            entity.setPublished(dto.getPublished());
        }
    }
}
