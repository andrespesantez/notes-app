import create from 'zustand';

interface Note {
  id: string;
  title: string;
  content: string;
}

interface NotesState {
  notes: Note[];
  loadNotes: () => void;
  createNote: (title: string, content: string) => void;
  updateNote: (id: string, title: string, content: string) => void;
  deleteNote: (id: string) => void;
  filterNotes: (query: string) => Note[];
}

export const useNotesStore = create<NotesState>((set) => ({
  notes: [],
  loadNotes: () => {
    // Logic to load notes from an API or local storage
  },
  createNote: (title, content) => {
    set((state) => ({
      notes: [...state.notes, { id: Date.now().toString(), title, content }],
    }));
  },
  updateNote: (id, title, content) => {
    set((state) => ({
      notes: state.notes.map((note) =>
        note.id === id ? { ...note, title, content } : note
      ),
    }));
  },
  deleteNote: (id) => {
    set((state) => ({
      notes: state.notes.filter((note) => note.id !== id),
    }));
  },
  filterNotes: (query) => {
    return query
      ? notes.filter((note) => note.title.includes(query) || note.content.includes(query))
      : notes;
  },
}));

export const NotesProvider = ({ children }) => {
  return <>{children}</>;
};

export const useNotes = () => useNotesStore();