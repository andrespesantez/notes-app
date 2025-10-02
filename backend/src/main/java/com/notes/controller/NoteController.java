package com.notes.controller;

import com.notes.dto.CreateNoteDto;
import com.notes.dto.NoteDto;
import com.notes.dto.UpdateNoteDto;
import com.notes.model.Note;
import com.notes.service.NoteService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/notes")
@CrossOrigin(origins = "*", allowedHeaders = "*", methods = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE, RequestMethod.OPTIONS})
public class NoteController {

    private final NoteService noteService;

    public NoteController(NoteService noteService) {
        this.noteService = noteService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<NoteDto>>> getAllNotes() {
        List<NoteDto> notes = noteService.getAllNotes();
        return ResponseEntity.ok(new ApiResponse<>("success", "Notes retrieved successfully", notes));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<NoteDto>> getNoteById(@PathVariable Long id) {
        NoteDto note = noteService.getNoteById(id);
        return ResponseEntity.ok(new ApiResponse<>("success", "Note found", note));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<NoteDto>> createNote(@Valid @RequestBody CreateNoteDto createNoteDto) {
        NoteDto createdNote = noteService.createNote(createNoteDto);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(new ApiResponse<>("success", "Note created successfully", createdNote));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<NoteDto>> updateNote(@PathVariable Long id,
                                                       @Valid @RequestBody UpdateNoteDto updateNoteDto) {
        NoteDto updatedNote = noteService.updateNote(id, updateNoteDto);
        return ResponseEntity.ok(new ApiResponse<>("success", "Note updated successfully", updatedNote));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteNote(@PathVariable Long id) {
        noteService.deleteNote(id);
        return ResponseEntity.ok(new ApiResponse<>("success", "Note deleted successfully", null));
    }

    @GetMapping("/search")
    public ResponseEntity<ApiResponse<List<NoteDto>>> searchNotes(@RequestParam String keyword) {
        List<NoteDto> notes = noteService.searchNotes(keyword);
        String message = notes.isEmpty() ? "No notes found with keyword: " + keyword :
                       "Found " + notes.size() + " notes";
        return ResponseEntity.ok(new ApiResponse<>("success", message, notes));
    }

    @GetMapping("/filter")
    public ResponseEntity<ApiResponse<List<NoteDto>>> filterNotes(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) Note.Priority priority) {
        List<NoteDto> notes = noteService.filterNotes(keyword, category, priority);
        String message = notes.isEmpty() ? "No notes found with the applied filters" :
                       "Found " + notes.size() + " notes";
        return ResponseEntity.ok(new ApiResponse<>("success", message, notes));
    }

    @GetMapping("/category/{category}")
    public ResponseEntity<ApiResponse<List<NoteDto>>> getNotesByCategory(@PathVariable String category) {
        List<NoteDto> notes = noteService.getNotesByCategory(category);
        String message = notes.isEmpty() ? "No notes in category: " + category :
                       "Found " + notes.size() + " notes in category: " + category;
        return ResponseEntity.ok(new ApiResponse<>("success", message, notes));
    }

    @GetMapping("/categories")
    public ResponseEntity<ApiResponse<List<String>>> getCategories() {
        List<String> categories = noteService.getAllCategories();
        return ResponseEntity.ok(new ApiResponse<>("success", "Categories retrieved successfully", categories));
    }

    @GetMapping("/priority/{priority}")
    public ResponseEntity<ApiResponse<List<NoteDto>>> getNotesByPriority(@PathVariable Note.Priority priority) {
        List<NoteDto> notes = noteService.getNotesByPriority(priority);
        String message = notes.isEmpty() ? "No notes with priority: " + priority.name() :
                       "Found " + notes.size() + " notes with priority: " + priority.name();
        return ResponseEntity.ok(new ApiResponse<>("success", message, notes));
    }

    @GetMapping("/recent")
    public ResponseEntity<ApiResponse<List<NoteDto>>> getRecentNotes() {
        List<NoteDto> notes = noteService.getRecentNotes();
        return ResponseEntity.ok(new ApiResponse<>("success", "Recent notes retrieved", notes));
    }

    @GetMapping("/stats")
    public ResponseEntity<ApiResponse<NoteService.NoteStats>> getStats() {
        NoteService.NoteStats stats = noteService.getStats();
        return ResponseEntity.ok(new ApiResponse<>("success", "Stats retrieved", stats));
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> healthCheck() {
        Map<String, Object> health = new HashMap<>();
        health.put("status", "UP");
        health.put("service", "Notes API");
        health.put("timestamp", System.currentTimeMillis());
        return ResponseEntity.ok(health);
    }

    public static class ApiResponse<T> {
        private String status;
        private String message;
        private T data;

        public ApiResponse(String status, String message, T data) {
            this.status = status;
            this.message = message;
            this.data = data;
        }

        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }

        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }

        public T getData() { return data; }
        public void setData(T data) { this.data = data; }
    }
}