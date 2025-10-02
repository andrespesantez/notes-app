package com.notes.service;

import com.notes.dto.CreateNoteDto;
import com.notes.dto.NoteDto;
import com.notes.dto.UpdateNoteDto;
import com.notes.exception.ResourceNotFoundException;
import com.notes.mapper.NoteMapper;
import com.notes.model.Note;
import com.notes.repository.NoteRepository;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class NoteService {

    private final NoteRepository noteRepository;
    private final NoteMapper noteMapper;

    public NoteService(NoteRepository noteRepository, NoteMapper noteMapper) {
        this.noteRepository = noteRepository;
        this.noteMapper = noteMapper;
    }

    public List<NoteDto> getAllNotes() {
        Sort sort = Sort.by(Sort.Direction.DESC, "updatedAt");
        return noteRepository.findAll(sort).stream()
                .map(noteMapper::toDto)
                .collect(Collectors.toList());
    }

    public NoteDto getNoteById(Long id) {
        Note note = noteRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Note not found with id: " + id));
        return noteMapper.toDto(note);
    }

    public NoteDto createNote(CreateNoteDto createNoteDto) {
        if (createNoteDto == null) {
            throw new IllegalArgumentException("Note cannot be null");
        }
        Note note = noteMapper.toEntity(createNoteDto);
        return noteMapper.toDto(noteRepository.save(note));
    }

    public NoteDto updateNote(Long id, UpdateNoteDto updateNoteDto) {
        Note existingNote = noteRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Note not found with id: " + id));

        noteMapper.updateEntityFromDto(updateNoteDto, existingNote);
        return noteMapper.toDto(noteRepository.save(existingNote));
    }

    public void deleteNote(Long id) {
        Note note = noteRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Note not found with id: " + id));
        noteRepository.delete(note);
    }

    public List<NoteDto> searchNotes(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return getAllNotes();
        }
        return noteRepository.findByKeyword(keyword.trim()).stream()
                .map(noteMapper::toDto)
                .collect(Collectors.toList());
    }

    public List<NoteDto> filterNotes(String keyword, String category, Note.Priority priority) {
        String normalizedKeyword = (keyword != null && !keyword.trim().isEmpty()) ? keyword.trim() : null;
        String normalizedCategory = (category != null && !category.trim().isEmpty()) ? category.trim() : null;

        return noteRepository.findByFilters(normalizedKeyword, normalizedCategory, priority).stream()
                .map(noteMapper::toDto)
                .collect(Collectors.toList());
    }

    public List<NoteDto> getNotesByCategory(String category) {
        if (category == null || category.trim().isEmpty()) {
            return getAllNotes();
        }
        Sort sort = Sort.by(Sort.Direction.DESC, "updatedAt");
        return noteRepository.findByCategory(category.trim(), sort).stream()
                .map(noteMapper::toDto)
                .collect(Collectors.toList());
    }

    public List<NoteDto> getNotesByPriority(Note.Priority priority) {
        if (priority == null) {
            return getAllNotes();
        }
        Sort sort = Sort.by(Sort.Direction.DESC, "updatedAt");
        return noteRepository.findByPriority(priority, sort).stream()
                .map(noteMapper::toDto)
                .collect(Collectors.toList());
    }

    public List<String> getAllCategories() {
        return noteRepository.findDistinctCategories();
    }

    public List<NoteDto> getRecentNotes() {
        return noteRepository.findTop10ByOrderByUpdatedAtDesc().stream()
                .map(noteMapper::toDto)
                .collect(Collectors.toList());
    }

    public NoteStats getStats() {
        long total = noteRepository.count();
        long high = noteRepository.countByPriority(Note.Priority.HIGH);
        long medium = noteRepository.countByPriority(Note.Priority.MEDIUM);
        long low = noteRepository.countByPriority(Note.Priority.LOW);

        return new NoteStats(total, high, medium, low);
    }

    public static class NoteStats {
        private final long total;
        private final long high;
        private final long medium;
        private final long low;

        public NoteStats(long total, long high, long medium, long low) {
            this.total = total;
            this.high = high;
            this.medium = medium;
            this.low = low;
        }

        public long getTotal() { return total; }
        public long getHigh() { return high; }
        public long getMedium() { return medium; }
        public long getLow() { return low; }
    }
}