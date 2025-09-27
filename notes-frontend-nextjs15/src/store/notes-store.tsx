"use client"

import { create } from "zustand"
import { subscribeWithSelector } from "zustand/middleware"
import { immer } from "zustand/middleware/immer"
import { createContext, useContext, ReactNode } from "react"
import { Note, NoteStats, NoteFormData } from "@/types"
import { notesApi } from "@/lib/api"
import toast from "react-hot-toast"

interface NotesState {
  // Data
  notes: Note[]
  filteredNotes: Note[]
  categories: string[]
  stats: NoteStats
  
  // UI State
  isLoading: boolean
  isFormLoading: boolean
  showForm: boolean
  editingNote: Note | null
  
  // Filters
  searchKeyword: string
  selectedCategory: string
  selectedPriority: string
  
  // Actions
  setNotes: (notes: Note[]) => void
  setFilteredNotes: (notes: Note[]) => void
  setCategories: (categories: string[]) => void
  setStats: (stats: NoteStats) => void
  setLoading: (loading: boolean) => void
  setFormLoading: (loading: boolean) => void
  setShowForm: (show: boolean) => void
  setEditingNote: (note: Note | null) => void
  setSearchKeyword: (keyword: string) => void
  setSelectedCategory: (category: string) => void
  setSelectedPriority: (priority: string) => void
  
  // Async Actions
  loadInitialData: () => Promise<void>
  createNote: (formData: NoteFormData) => Promise<void>
  updateNote: (id: number, formData: NoteFormData) => Promise<void>
  deleteNote: (id: number) => Promise<void>
  searchNotes: (keyword: string) => Promise<void>
  filterNotes: () => Promise<void>
  refreshData: () => Promise<void>
}

const useNotesStore = create<NotesState>()(
  subscribeWithSelector(
    immer((set, get) => ({
      // Initial state
      notes: [],
      filteredNotes: [],
      categories: [],
      stats: { total: 0, high: 0, medium: 0, low: 0 },
      isLoading: true,
      isFormLoading: false,
      showForm: false,
      editingNote: null,
      searchKeyword: "",
      selectedCategory: "",
      selectedPriority: "",

      // Setters
      setNotes: (notes) => set((state) => { state.notes = notes }),
      setFilteredNotes: (notes) => set((state) => { state.filteredNotes = notes }),
      setCategories: (categories) => set((state) => { state.categories = categories }),
      setStats: (stats) => set((state) => { state.stats = stats }),
      setLoading: (loading) => set((state) => { state.isLoading = loading }),
      setFormLoading: (loading) => set((state) => { state.isFormLoading = loading }),
      setShowForm: (show) => set((state) => { state.showForm = show }),
      setEditingNote: (note) => set((state) => { state.editingNote = note }),
      setSearchKeyword: (keyword) => set((state) => { state.searchKeyword = keyword }),
      setSelectedCategory: (category) => set((state) => { state.selectedCategory = category }),
      setSelectedPriority: (priority) => set((state) => { state.selectedPriority = priority }),

      // Async actions
      loadInitialData: async () => {
        try {
          set((state) => { state.isLoading = true })
          
          const [notesData, categoriesData, statsData] = await Promise.all([
            notesApi.getAllNotes(),
            notesApi.getCategories(),
            notesApi.getStats(),
          ])

          set((state) => {
            state.notes = notesData
            state.filteredNotes = notesData
            state.categories = categoriesData
            state.stats = statsData
          })
        } catch (error) {
          console.error("Error loading initial data:", error)
          toast.error("Error al cargar los datos iniciales")
        } finally {
          set((state) => { state.isLoading = false })
        }
      },

      createNote: async (formData) => {
        try {
          set((state) => { state.isFormLoading = true })
          
          await notesApi.createNote(formData)
          
          set((state) => {
            state.showForm = false
            state.editingNote = null
          })
          
          toast.success("Nota creada correctamente")
          await get().loadInitialData()
        } catch (error) {
          console.error("Error creating note:", error)
          toast.error("Error al crear la nota")
        } finally {
          set((state) => { state.isFormLoading = false })
        }
      },

      updateNote: async (id, formData) => {
        try {
          set((state) => { state.isFormLoading = true })
          
          await notesApi.updateNote(id, formData)
          
          set((state) => {
            state.showForm = false
            state.editingNote = null
          })
          
          toast.success("Nota actualizada correctamente")
          await get().loadInitialData()
        } catch (error) {
          console.error("Error updating note:", error)
          toast.error("Error al actualizar la nota")
        } finally {
          set((state) => { state.isFormLoading = false })
        }
      },

      deleteNote: async (id) => {
        try {
          await notesApi.deleteNote(id)
          toast.success("Nota eliminada correctamente")
          await get().loadInitialData()
        } catch (error) {
          console.error("Error deleting note:", error)
          toast.error("Error al eliminar la nota")
        }
      },

      searchNotes: async (keyword) => {
        try {
          if (!keyword.trim()) {
            set((state) => { state.filteredNotes = state.notes })
            return
          }
          
          const filtered = await notesApi.searchNotes(keyword)
          set((state) => { state.filteredNotes = filtered })
        } catch (error) {
          console.error("Error searching notes:", error)
          toast.error("Error en la búsqueda")
        }
      },

      filterNotes: async () => {
        try {
          const { searchKeyword, selectedCategory, selectedPriority, notes } = get()
          
          if (!searchKeyword && !selectedCategory && !selectedPriority) {
            set((state) => { state.filteredNotes = state.notes })
            return
          }

          const filtered = await notesApi.filterNotes({
            keyword: searchKeyword || undefined,
            category: selectedCategory || undefined,
            priority: selectedPriority as Note["priority"] || undefined,
          })

          set((state) => { state.filteredNotes = filtered })
        } catch (error) {
          console.error("Error filtering notes:", error)
          toast.error("Error al aplicar filtros")
        }
      },

      refreshData: async () => {
        await get().loadInitialData()
        toast.success("Datos actualizados correctamente")
      },
    }))
  )
)

const NotesContext = createContext<ReturnType<typeof useNotesStore> | null>(null)

export function NotesProvider({ children }: { children: ReactNode }) {
  return (
    <NotesContext.Provider value={useNotesStore}>
      {children}
    </NotesContext.Provider>
  )
}

export const useNotes = () => {
  const context = useContext(NotesContext)
  if (!context) {
    throw new Error("useNotes must be used within NotesProvider")
  }
  return context()
}
