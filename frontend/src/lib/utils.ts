// src/lib/utils.ts
import { Note } from '@/types';
import clsx, { ClassValue } from 'clsx';

export function cn(...inputs: ClassValue[]) {
  return clsx(inputs);
}

export const getPriorityColor = (priority: Note['priority']) => {
  switch (priority) {
    case 'HIGH':
      return {
        bg: 'bg-red-500',
        text: 'text-red-700',
        border: 'border-red-500',
        light: 'bg-red-50',
        gradient: 'from-red-500 to-red-600',
      };
    case 'MEDIUM':
      return {
        bg: 'bg-yellow-500',
        text: 'text-yellow-700',
        border: 'border-yellow-500',
        light: 'bg-yellow-50',
        gradient: 'from-yellow-500 to-yellow-600',
      };
    case 'LOW':
      return {
        bg: 'bg-green-500',
        text: 'text-green-700',
        border: 'border-green-500',
        light: 'bg-green-50',
        gradient: 'from-green-500 to-green-600',
      };
    default:
      return {
        bg: 'bg-gray-500',
        text: 'text-gray-700',
        border: 'border-gray-500',
        light: 'bg-gray-50',
        gradient: 'from-gray-500 to-gray-600',
      };
  }
};

export const getPriorityLabel = (priority: Note['priority']) => {
  switch (priority) {
    case 'HIGH': return '🔴 Alta';
    case 'MEDIUM': return '🟡 Media';
    case 'LOW': return '🟢 Baja';
    default: return '⚪ Sin definir';
  }
};

export const formatDate = (dateString: string): string => {
  try {
    const date = new Date(dateString);
    const now = new Date();
    const diffInMs = now.getTime() - date.getTime();
    const diffInHours = diffInMs / (1000 * 60 * 60);
    const diffInDays = diffInMs / (1000 * 60 * 60 * 24);

    // Si es hoy
    if (diffInDays < 1 && date.getDate() === now.getDate()) {
      if (diffInHours < 1) {
        const diffInMinutes = Math.floor(diffInMs / (1000 * 60));
        return diffInMinutes < 1 ? 'Ahora mismo' : `Hace ${diffInMinutes} min`;
      }
      return `Hace ${Math.floor(diffInHours)} h`;
    }

    // Si es ayer
    if (diffInDays < 2 && diffInDays >= 1) {
      return `Ayer ${date.toLocaleTimeString('es-ES', { 
        hour: '2-digit', 
        minute: '2-digit' 
      })}`;
    }

    // Si es esta semana
    if (diffInDays < 7) {
      return date.toLocaleDateString('es-ES', { 
        weekday: 'long',
        hour: '2-digit',
        minute: '2-digit'
      });
    }

    // Fecha completa
    return new Intl.DateTimeFormat('es-ES', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    }).format(date);
  } catch (error) {
    console.error('Error formatting date:', error);
    return 'Fecha inválida';
  }
};

export const truncateText = (text: string, maxLength: number = 150): string => {
  if (!text || text.length <= maxLength) return text;
  return text.substring(0, maxLength).trim() + '...';
};

export const getCategoryIcon = (category: string): string => {
  const categoryLower = category.toLowerCase();
  
  const iconMap: Record<string, string> = {
    trabajo: '💼',
    personal: '👤',
    estudio: '📚',
    estudios: '📚',
    idea: '💡',
    ideas: '💡',
    compra: '🛒',
    compras: '🛒',
    salud: '🏥',
    familia: '👨‍👩‍👧‍👦',
    casa: '🏠',
    hogar: '🏠',
    viaje: '✈️',
    viajes: '✈️',
    deporte: '⚽',
    deportes: '⚽',
    cocina: '👨‍🍳',
    música: '🎵',
    musica: '🎵',
    libro: '📖',
    libros: '📖',
    película: '🎬',
    peliculas: '🎬',
    cine: '🎬',
    finanzas: '💰',
    dinero: '💰',
  };

  for (const [key, icon] of Object.entries(iconMap)) {
    if (categoryLower.includes(key)) {
      return icon;
    }
  }

  return '📁';
};

export const validateNote = (note: Partial<Note>): string[] => {
  const errors: string[] = [];

  if (!note.title || note.title.trim().length === 0) {
    errors.push('El título es obligatorio');
  } else if (note.title.length > 255) {
    errors.push('El título no puede exceder 255 caracteres');
  }

  if (!note.category || note.category.trim().length === 0) {
    errors.push('La categoría es obligatoria');
  } else if (note.category.length > 100) {
    errors.push('La categoría no puede exceder 100 caracteres');
  }

  if (note.priority && !['LOW', 'MEDIUM', 'HIGH'].includes(note.priority)) {
    errors.push('La prioridad debe ser LOW, MEDIUM o HIGH');
  }

  return errors;
};

export const searchInNote = (note: Note, query: string): boolean => {
  if (!query.trim()) return true;
  
  const searchTerm = query.toLowerCase();
  const searchFields = [
    note.title,
    note.content,
    note.category,
  ].filter(Boolean);

  return searchFields.some(field => 
    field.toLowerCase().includes(searchTerm)
  );
};

export const sortNotes = (notes: Note[], sortBy: 'date' | 'title' | 'priority' = 'date'): Note[] => {
  return [...notes].sort((a, b) => {
    switch (sortBy) {
      case 'title':
        return a.title.localeCompare(b.title);
      case 'priority':
        const priorityOrder = { HIGH: 3, MEDIUM: 2, LOW: 1 };
        return priorityOrder[b.priority] - priorityOrder[a.priority];
      case 'date':
      default:
        return new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime();
    }
  });
};

export const exportToJSON = (notes: Note[]): string => {
  return JSON.stringify(notes, null, 2);
};

export const exportToCSV = (notes: Note[]): string => {
  const headers = ['ID', 'Título', 'Contenido', 'Categoría', 'Prioridad', 'Creado', 'Actualizado'];
  const csvContent = [
    headers.join(','),
    ...notes.map(note => [
      note.id,
      `"${note.title.replace(/"/g, '""')}"`,
      `"${(note.content || '').replace(/"/g, '""')}"`,
      `"${note.category.replace(/"/g, '""')}"`,
      note.priority,
      note.createdAt,
      note.updatedAt,
    ].join(','))
  ].join('\n');

  return csvContent;
};

export const generateNoteId = (): string => {
  return Date.now().toString(36) + Math.random().toString(36).substr(2);
};