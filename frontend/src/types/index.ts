export interface Note {
  id: number;
  title: string;
  content: string;
  category: string;
  priority: "LOW" | "MEDIUM" | "HIGH";
  createdAt: string;
  updatedAt: string;
}

export interface ApiResponse<T> {
  status: "success" | "error";
  message: string;
  data: T;
}

export interface NoteStats {
  total: number;
  high: number;
  medium: number;
  low: number;
}

export interface NoteFormData {
  title: string;
  content: string;
  category: string;
  priority: Note["priority"];
}

export interface FilterOptions {
  keyword?: string;
  category?: string;
  priority?: Note["priority"];
}

export interface ViewMode {
  type: "grid" | "list" | "compact";
  columns: number;
}

export interface Theme {
  mode: "light" | "dark" | "system";
  primary: string;
  accent: string;
}
