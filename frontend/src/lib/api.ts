import axios from "axios";
import { Note, ApiResponse, NoteStats, FilterOptions } from "@/types";

const API_BASE_URL = typeof window === 'undefined'
  ? 'http://nginx-proxy/api' // URL para SSR dentro de Docker
  : '/api'; // URL relativa para el cliente (navegador)

// Crear instancia de axios con configuración base
const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
  },
  timeout: 15000,
});

// Interceptors para logging y manejo de errores
api.interceptors.request.use(
  (config) => {
    if (process.env.NODE_ENV === "development") {
      console.log(`🌐 ${config.method?.toUpperCase()} ${config.url}`, config.data);
    }
    return config;
  },
  (error) => {
    console.error("Request error:", error);
    return Promise.reject(error);
  }
);

api.interceptors.response.use(
  (response) => {
    if (process.env.NODE_ENV === "development") {
      console.log(`✅ ${response.config.method?.toUpperCase()} ${response.config.url}`, response.data);
    }
    return response;
  },
  (error) => {
    console.error("Response error:", error);
    
    // Manejo específico de errores de red
    if (error.code === "ECONNABORTED") {
      throw new Error("La solicitud tardó demasiado tiempo. Verifica tu conexión.");
    }
    
    if (!error.response) {
      throw new Error("Error de conexión. Verifica que el servidor esté disponible.");
    }
    
    const status = error.response.status;
    const message = error.response.data?.message || error.message;
    
    switch (status) {
      case 400:
        throw new Error(`Solicitud inválida: ${message}`);
      case 401:
        throw new Error("No autorizado");
      case 403:
        throw new Error("Acceso denegado");
      case 404:
        throw new Error("Recurso no encontrado");
      case 500:
        throw new Error("Error interno del servidor");
      default:
        throw new Error(message || "Error desconocido");
    }
  }
);

// API functions
export const notesApi = {
  // Obtener todas las notas
  getAllNotes: async (): Promise<Note[]> => {
    try {
      const response = await api.get<ApiResponse<Note[]>>("/notes");
      return response.data.data || [];
    } catch (error) {
      console.error("Error fetching notes:", error);
      throw error;
    }
  },

  // Obtener nota por ID
  getNoteById: async (id: number): Promise<Note> => {
    const response = await api.get<ApiResponse<Note>>(`/notes/${id}`);
    if (response.data.status === "error") {
      throw new Error(response.data.message);
    }
    return response.data.data;
  },

  // Crear nueva nota
  createNote: async (note: Omit<Note, "id" | "createdAt" | "updatedAt">): Promise<Note> => {
    const response = await api.post<ApiResponse<Note>>("/notes", note);
    if (response.data.status === "error") {
      throw new Error(response.data.message);
    }
    return response.data.data;
  },

  // Actualizar nota
  updateNote: async (id: number, note: Partial<Note>): Promise<Note> => {
    const response = await api.put<ApiResponse<Note>>(`/notes/${id}`, note);
    if (response.data.status === "error") {
      throw new Error(response.data.message);
    }
    return response.data.data;
  },

  // Eliminar nota
  deleteNote: async (id: number): Promise<void> => {
    const response = await api.delete<ApiResponse<void>>(`/notes/${id}`);
    if (response.data.status === "error") {
      throw new Error(response.data.message);
    }
  },

  // Buscar notas por palabra clave
  searchNotes: async (keyword: string): Promise<Note[]> => {
    const response = await api.get<ApiResponse<Note[]>>(`/notes/search`, {
      params: { keyword: keyword.trim() }
    });
    return response.data.data || [];
  },

  // Filtrar notas con múltiples criterios
  filterNotes: async (filters: FilterOptions): Promise<Note[]> => {
    const cleanFilters = Object.fromEntries(
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
      Object.entries(filters).filter(([_, value]) => value !== undefined && value !== null && value !== "")
    );
    
    const response = await api.get<ApiResponse<Note[]>>("/notes/filter", {
      params: cleanFilters
    });
    return response.data.data || [];
  },

  // Obtener todas las categorías
  getCategories: async (): Promise<string[]> => {
    try {
      const response = await api.get<ApiResponse<string[]>>("/notes/categories");
      return response.data.data || [];
    } catch (error) {
      console.error("Error fetching categories:", error);
      return [];
    }
  },

  // Obtener estadísticas
  getStats: async (): Promise<NoteStats> => {
    const response = await api.get<ApiResponse<NoteStats>>("/notes/stats");
    if (response.data.status === "error") {
      throw new Error(response.data.message);
    }
    return response.data.data || { total: 0, high: 0, medium: 0, low: 0 };
  },

  // Obtener notas recientes
  getRecentNotes: async (limit: number = 10): Promise<Note[]> => {
    const response = await api.get<ApiResponse<Note[]>>("/notes/recent", {
      params: { limit }
    });
    return response.data.data || [];
  },

  // Health check
  healthCheck: async (): Promise<boolean> => {
    try {
      const response = await api.get("/notes/health");
      return response.status === 200;
    } catch (error) {
      return false;
    }
  },
};
