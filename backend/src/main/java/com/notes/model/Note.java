// src/main/java/com/notes/model/Note.java
package com.notes.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import com.fasterxml.jackson.annotation.JsonFormat;
import java.time.LocalDateTime;

@Entity
@Table(name = "notes", indexes = {
    @Index(name = "idx_category", columnList = "category"),
    @Index(name = "idx_created_at", columnList = "created_at"),
    @Index(name = "idx_priority", columnList = "priority")
})
@NoArgsConstructor
@Getter
@Setter
public class Note {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @NotBlank(message = "El título es obligatorio")
    @Size(max = 255, message = "El título no puede exceder 255 caracteres")
    @Column(nullable = false)
    private String title;
    
    @Column(columnDefinition = "TEXT")
    private String content;
    
    @Column(name = "created_at", nullable = false, updatable = false)
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at", nullable = false)
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime updatedAt;
    
    @Size(max = 100, message = "La categoría no puede exceder 100 caracteres")
    @Column(nullable = false)
    private String category = "General";
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Priority priority = Priority.MEDIUM;
    
    public enum Priority {
        LOW("Baja"), 
        MEDIUM("Media"), 
        HIGH("Alta");
        
        private final String displayName;
        
        Priority(String displayName) {
            this.displayName = displayName;
        }
        
        public String getDisplayName() {
            return displayName;
        }
    }
    
    @PrePersist
    protected void onCreate() {
        LocalDateTime now = LocalDateTime.now();
        createdAt = now;
        updatedAt = now;
        if (category == null || category.trim().isEmpty()) {
            category = "General";
        }
        if (priority == null) {
            priority = Priority.MEDIUM;
        }
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
        if (category == null || category.trim().isEmpty()) {
            category = "General";
        }
        if (priority == null) {
            priority = Priority.MEDIUM;
        }
    }
    
    // Constructors
    public Note() {}
    
    public Note(String title, String content) {
        this.title = title;
        this.content = content;
        this.category = "General";
        this.priority = Priority.MEDIUM;
    }
    
    public Note(String title, String content, String category, Priority priority) {
        this.title = title;
        this.content = content;
        this.category = category != null ? category : "General";
        this.priority = priority != null ? priority : Priority.MEDIUM;
    }
    
    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    
    public String getCategory() { return category; }
    public void setCategory(String category) { 
        this.category = category != null && !category.trim().isEmpty() ? category : "General"; 
    }
    
    public Priority getPriority() { return priority; }
    public void setPriority(Priority priority) { 
        this.priority = priority != null ? priority : Priority.MEDIUM; 
    }
    
    @Override
    public String toString() {
        return "Note{" +
                "id=" + id +
                ", title='" + title + '\'' +
                ", category='" + category + '\'' +
                ", priority=" + priority +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}