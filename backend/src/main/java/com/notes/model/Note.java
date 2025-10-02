package com.notes.model;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Entity
@Table(name = "notes", indexes = {
    @Index(name = "idx_category", columnList = "category"),
    @Index(name = "idx_created_at", columnList = "created_at"),
    @Index(name = "idx_priority", columnList = "priority")
})
@EntityListeners(AuditingEntityListener.class)
@NoArgsConstructor
@Getter
@Setter
public class Note {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Title is mandatory")
    @Size(max = 255, message = "Title cannot exceed 255 characters")
    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String content;

    @Column(nullable = false)
    private boolean published = false;

    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime createdAt;

    @LastModifiedDate
    @Column(name = "updated_at", nullable = false)
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime updatedAt;

    @Size(max = 100, message = "Category cannot exceed 100 characters")
    @Column(nullable = false)
    private String category = "General";

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Priority priority = Priority.MEDIUM;

    public enum Priority {
        LOW("Low"),
        MEDIUM("Medium"),
        HIGH("High");

        private final String displayName;

        Priority(String displayName) {
            this.displayName = displayName;
        }

        public String getDisplayName() {
            return displayName;
        }
    }

    public Note(String title, String content) {
        this.title = title;
        this.content = content;
        this.category = "General";
        this.priority = Priority.MEDIUM;
    }

    public Note(String title, String content, String category, Priority priority, boolean published) {
        this.title = title;
        this.content = content;
        this.category = category != null ? category : "General";
        this.priority = priority != null ? priority : Priority.MEDIUM;
        this.published = published;
    }

    public void setCategory(String category) {
        this.category = category != null && !category.trim().isEmpty() ? category : "General";
    }
    
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
