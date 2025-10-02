// src/main/java/com/notes/repository/NoteRepository.java
package com.notes.repository;

import com.notes.model.Note;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface NoteRepository extends JpaRepository<Note, Long> {
    
    // Búsquedas básicas
    List<Note> findByCategory(String category, Sort sort);
    List<Note> findByPriority(Note.Priority priority, Sort sort);
    
    // Búsqueda por palabras clave
    @Query("SELECT n FROM Note n WHERE LOWER(n.title) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(n.content) LIKE LOWER(CONCAT('%', :keyword, '%')) ORDER BY n.updatedAt DESC")
    List<Note> findByKeyword(@Param("keyword") String keyword);
    
    // Búsqueda combinada
    @Query("SELECT n FROM Note n WHERE " +
           "(:keyword IS NULL OR LOWER(n.title) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(n.content) LIKE LOWER(CONCAT('%', :keyword, '%'))) AND " +
           "(:category IS NULL OR n.category = :category) AND " +
           "(:priority IS NULL OR n.priority = :priority) " +
           "ORDER BY n.updatedAt DESC")
    List<Note> findByFilters(@Param("keyword") String keyword, 
                           @Param("category") String category, 
                           @Param("priority") Note.Priority priority);
    
    // Obtener categorías únicas
    @Query("SELECT DISTINCT n.category FROM Note n WHERE n.category IS NOT NULL ORDER BY n.category ASC")
    List<String> findDistinctCategories();
    
    // Estadísticas
    @Query("SELECT COUNT(n) FROM Note n WHERE n.priority = :priority")
    Long countByPriority(@Param("priority") Note.Priority priority);
    
    @Query("SELECT COUNT(n) FROM Note n WHERE n.category = :category")
    Long countByCategory(@Param("category") String category);
    
    // Notas recientes
    List<Note> findTop10ByOrderByUpdatedAtDesc();
    
    // Notas por rango de fechas
    List<Note> findByCreatedAtBetween(LocalDateTime start, LocalDateTime end, Sort sort);
    
    // Buscar por ID con validación
    @Query("SELECT n FROM Note n WHERE n.id = :id")
    Optional<Note> findByIdSafe(@Param("id") Long id);
}