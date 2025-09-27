-- Inicialización de la base de datos para el sistema de notas
USE notes_db;

-- Crear tabla de notas
CREATE TABLE IF NOT EXISTS notes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    category VARCHAR(100) DEFAULT 'General',
    priority ENUM('LOW', 'MEDIUM', 'HIGH') DEFAULT 'MEDIUM'
);

-- Insertar algunas notas de ejemplo
INSERT INTO notes (title, content, category, priority) VALUES 
('Bienvenida', 'Esta es tu primera nota en el sistema. ¡Puedes crear, editar y eliminar notas fácilmente!', 'Tutorial', 'HIGH'),
('Lista de compras', 'Leche, Pan, Huevos, Frutas, Verduras', 'Personal', 'MEDIUM'),
('Reunión de trabajo', 'Discutir el nuevo proyecto, revisar presupuesto, asignar tareas', 'Trabajo', 'HIGH'),
('Ideas para el fin de semana', 'Visitar el parque, ver una película, cocinar algo especial', 'Personal', 'LOW');

-- Crear índices para mejorar el rendimiento
CREATE INDEX idx_category ON notes(category);
CREATE INDEX idx_created_at ON notes(created_at);
CREATE INDEX idx_priority ON notes(priority);