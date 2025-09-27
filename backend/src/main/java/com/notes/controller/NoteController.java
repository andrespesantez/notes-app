// src/main/java/com/notes/controller/NoteController.java
package com.notes.controller;

import com.notes.model.Note;
import com.notes.service.NoteService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.validation.BindingResult;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/notes")
@CrossOrigin(origins = "*", allowedHeaders = "*", methods = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE, RequestMethod.OPTIONS})
public class NoteController {
    
    @Autowired
    private NoteService noteService;
    
    /**
     * Obtener todas las notas
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<Note>>> getAllNotes() {
        try {
            List<Note> notes = noteService.getAllNotes();
            return ResponseEntity.ok(new ApiResponse<>("success", "Notas obtenidas correctamente", notes));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>("error", "Error al obtener las notas: " + e.getMessage(), null));
        }
    }
    
    /**
     * Obtener nota por ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Note>> getNoteById(@PathVariable Long id) {
        try {
            return noteService.getNoteById(id)
                    .map(note -> ResponseEntity.ok(new ApiResponse<>("success", "Nota encontrada", note)))
                    .orElse(ResponseEntity.status(HttpStatus.NOT_FOUND)
                            .body(new ApiResponse<>("error", "Nota no encontrada", null)));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>("error", "Error al obtener la nota: " + e.getMessage(), null));
        }
    }
    
    /**
     * Crear nueva nota
     */
    @PostMapping
    public ResponseEntity<ApiResponse<Note>> createNote(@Valid @RequestBody Note note, BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                String errors = bindingResult.getFieldErrors().stream()
                        .map(error -> error.getField() + ": " + error.getDefaultMessage())
                        .collect(Collectors.joining(", "));
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(new ApiResponse<>("error", "Errores de validación: " + errors, null));
            }
            
            Note createdNote = noteService.createNote(note);
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(new ApiResponse<>("success", "Nota creada correctamente", createdNote));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ApiResponse<>("error", e.getMessage(), null));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>("error", "Error al crear la nota: " + e.getMessage(), null));
        }
    }
    
    /**
     * Actualizar nota existente
     */
    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<Note>> updateNote(@PathVariable Long id, 
                                                       @Valid @RequestBody Note noteDetails, 
                                                       BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                String errors = bindingResult.getFieldErrors().stream()
                        .map(error -> error.getField() + ": " + error.getDefaultMessage())
                        .collect(Collectors.joining(", "));
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(new ApiResponse<>("error", "Errores de validación: " + errors, null));
            }
            
            return noteService.updateNote(id, noteDetails)
                    .map(updatedNote -> ResponseEntity.ok(new ApiResponse<>("success", "Nota actualizada correctamente", updatedNote)))
                    .orElse(ResponseEntity.status(HttpStatus.NOT_FOUND)
                            .body(new ApiResponse<>("error", "Nota no encontrada", null)));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ApiResponse<>("error", e.getMessage(), null));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>("error", "Error al actualizar la nota: " + e.getMessage(), null));
        }
    }
    
    /**
     * Eliminar nota
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteNote(@PathVariable Long id) {
        try {
            boolean deleted = noteService.deleteNote(id);
            if (deleted) {
                return ResponseEntity.ok(new ApiResponse<>("success", "Nota eliminada correctamente", null));
            } else {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(new ApiResponse<>("error", "Nota no encontrada", null));
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>("error", "Error al eliminar la nota: " + e.getMessage(), null));
        }
    }
    
    /**
     * Buscar notas por palabra clave
     */
    @GetMapping("/search")
    public ResponseEntity<ApiResponse<List<Note>>> searchNotes(@RequestParam String keyword) {
        try {
            List<Note> notes = noteService.searchNotes(keyword);
            String message = notes.isEmpty() ? "No se encontraron notas con la palabra clave: " + keyword : 
                           "Se encontraron " + notes.size() + " notas";
            return ResponseEntity.ok(new ApiResponse<>("success", message, notes));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>("error", "Error en la búsqueda: " + e.getMessage(), null));
        }
    }
    
    /**
     * Filtrar notas por múltiples criterios
     */
    @GetMapping("/filter")
    public ResponseEntity<ApiResponse<List<Note>>> filterNotes(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) Note.Priority priority) {
        try {
            List<Note> notes = noteService.filterNotes(keyword, category, priority);
            String message = notes.isEmpty() ? "No se encontraron notas con los filtros aplicados" : 
                           "Se encontraron " + notes.size() + " notas";
            return ResponseEntity.ok(new ApiResponse<>("success", message, notes));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>("error", "Error al filtrar notas: " + e.getMessage(), null));
        }
    }
    
    /**
     * Obtener notas por categoría
     */
    @GetMapping("/category/{category}")
    public ResponseEntity<ApiResponse<List<Note>>> getNotesByCategory(@PathVariable String category) {
        try {
            List<Note> notes = noteService.getNotesByCategory(category);
            String message = notes.isEmpty() ? "No hay notas en la categoría: " + category : 
                           "Se encontraron " + notes.size() + " notas en la categoría: " + category;
            return ResponseEntity.ok(new ApiResponse<>("success", message, notes));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>("error", "Error al obtener notas por categoría: " + e.getMessage(), null));
        }
    }
    
    /**
     * Obtener todas las categorías disponibles
     */
    @GetMapping("/categories")
    public ResponseEntity<ApiResponse<List<String>>> getCategories() {
        try {
            List<String> categories = noteService.getAllCategories();
            return ResponseEntity.ok(new ApiResponse<>("success", "Categorías obtenidas correctamente", categories));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>("error", "Error al obtener categorías: " + e.getMessage(), null));
        }
    }
    
    /**
     * Obtener notas por prioridad
     */
    @GetMapping("/priority/{priority}")
    public ResponseEntity<ApiResponse<List<Note>>> getNotesByPriority(@PathVariable Note.Priority priority) {
        try {
            List<Note> notes = noteService.getNotesByPriority(priority);
            String message = notes.isEmpty() ? "No hay notas con prioridad: " + priority.getDisplayName() : 
                           "Se encontraron " + notes.size() + " notas con prioridad: " + priority.getDisplayName();
            return ResponseEntity.ok(new ApiResponse<>("success", message, notes));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>("error", "Error al obtener notas por prioridad: " + e.getMessage(), null));
        }
    }
    
    /**
     * Obtener notas recientes
     */
    @GetMapping("/recent")
    public ResponseEntity<ApiResponse<List<Note>>> getRecentNotes() {
        try {
            List<Note> notes = noteService.getRecentNotes();
            return ResponseEntity.ok(new ApiResponse<>("success", "Notas recientes obtenidas", notes));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>("error", "Error al obtener notas recientes: " + e.getMessage(), null));
        }
    }
    
    /**
     * Obtener estadísticas
     */
    @GetMapping("/stats")
    public ResponseEntity<ApiResponse<NoteService.NoteStats>> getStats() {
        try {
            NoteService.NoteStats stats = noteService.getStats();
            return ResponseEntity.ok(new ApiResponse<>("success", "Estadísticas obtenidas", stats));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>("error", "Error al obtener estadísticas: " + e.getMessage(), null));
        }
    }
    
    /**
     * Health check endpoint
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> healthCheck() {
        Map<String, Object> health = new HashMap<>();
        health.put("status", "UP");
        health.put("service", "Notes API");
        health.put("timestamp", System.currentTimeMillis());
        return ResponseEntity.ok(health);
    }
    
    /**
     * Clase para respuestas consistentes de la API
     */
    public static class ApiResponse<T> {
        private String status;
        private String message;
        private T data;
        
        public ApiResponse(String status, String message, T data) {
            this.status = status;
            this.message = message;
            this.data = data;
        }
        
        // Getters y setters
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
        
        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
        
        public T getData() { return data; }
        public void setData(T data) { this.data = data; }
    }
}