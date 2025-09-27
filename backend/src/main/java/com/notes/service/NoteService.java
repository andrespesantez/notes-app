// src/main/java/com/notes/service/NoteService.java
package com.notes.service;

import com.notes.model.Note;
import com.notes.repository.NoteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class NoteService {
    
    @Autowired
    private NoteRepository noteRepository;
    
    // Obtener todas las notas ordenadas por fecha de actualización
    public List<Note> getAllNotes() {
        Sort sort = Sort.by(Sort.Direction.DESC, "updatedAt");
        return noteRepository.findAll(sort);
    }
    
    // Obtener nota por ID
    public Optional<Note> getNoteById(Long id) {
        if (id == null || id <= 0) {
            return Optional.empty();
        }
        return noteRepository.findByIdSafe(id);
    }
    
    // Crear nueva nota
    public Note createNote(Note note) {
        if (note == null) {
            throw new IllegalArgumentException("La nota no puede ser null");
        }
        
        // Validaciones adicionales
        if (note.getTitle() == null || note.getTitle().trim().isEmpty()) {
            throw new IllegalArgumentException("El título es obligatorio");
        }
        
        // Limpiar datos
        note.setTitle(note.getTitle().trim());
        if (note.getContent() != null) {
            note.setContent(note.getContent().trim());
        }
        
        return noteRepository.save(note);
    }
    
    // Actualizar nota existente
    public Optional<Note> updateNote(Long id, Note noteDetails) {
        if (id == null || id <= 0) {
            return Optional.empty();
        }
        
        return noteRepository.findByIdSafe(id).map(existingNote -> {
            // Actualizar campos
            if (noteDetails.getTitle() != null && !noteDetails.getTitle().trim().isEmpty()) {
                existingNote.setTitle(noteDetails.getTitle().trim());
            }
            
            if (noteDetails.getContent() != null) {
                existingNote.setContent(noteDetails.getContent().trim());
            }
            
            if (noteDetails.getCategory() != null) {
                existingNote.setCategory(noteDetails.getCategory().trim());
            }
            
            if (noteDetails.getPriority() != null) {
                existingNote.setPriority(noteDetails.getPriority());
            }
            
            return noteRepository.save(existingNote);
        });
    }
    
    // Eliminar nota
    public boolean deleteNote(Long id) {
        if (id == null || id <= 0) {
            return false;
        }
        
        return noteRepository.findByIdSafe(id).map(note -> {
            noteRepository.delete(note);
            return true;
        }).orElse(false);
    }
    
    // Buscar notas
    public List<Note> searchNotes(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return getAllNotes();
        }
        return noteRepository.findByKeyword(keyword.trim());
    }
    
    // Filtrar notas
    public List<Note> filterNotes(String keyword, String category, Note.Priority priority) {
        // Normalizar parámetros
        String normalizedKeyword = (keyword != null && !keyword.trim().isEmpty()) ? keyword.trim() : null;
        String normalizedCategory = (category != null && !category.trim().isEmpty()) ? category.trim() : null;
        
        return noteRepository.findByFilters(normalizedKeyword, normalizedCategory, priority);
    }
    
    // Obtener notas por categoría
    public List<Note> getNotesByCategory(String category) {
        if (category == null || category.trim().isEmpty()) {
            return getAllNotes();
        }
        Sort sort = Sort.by(Sort.Direction.DESC, "updatedAt");
        return noteRepository.findByCategory(category.trim(), sort);
    }
    
    // Obtener notas por prioridad
    public List<Note> getNotesByPriority(Note.Priority priority) {
        if (priority == null) {
            return getAllNotes();
        }
        Sort sort = Sort.by(Sort.Direction.DESC, "updatedAt");
        return noteRepository.findByPriority(priority, sort);
    }
    
    // Obtener todas las categorías
    public List<String> getAllCategories() {
        return noteRepository.findDistinctCategories();
    }
    
    // Obtener notas recientes
    public List<Note> getRecentNotes() {
        return noteRepository.findTop10ByOrderByUpdatedAtDesc();
    }
    
    // Obtener estadísticas
    public NoteStats getStats() {
        long total = noteRepository.count();
        long high = noteRepository.countByPriority(Note.Priority.HIGH);
        long medium = noteRepository.countByPriority(Note.Priority.MEDIUM);
        long low = noteRepository.countByPriority(Note.Priority.LOW);
        
        return new NoteStats(total, high, medium, low);
    }
    
    // Clase para estadísticas
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