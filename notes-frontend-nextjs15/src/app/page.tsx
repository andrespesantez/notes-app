// src/app/page.tsx
'use client'

import { useEffect } from 'react'
import { motion } from 'framer-motion'
import { FileText, Plus, Filter, Grid3X3, List, BarChart3 } from 'lucide-react'
import { Header } from '@/components/layout/Header'
import { NoteCard } from '@/components/notes/NoteCard'
import { NoteForm } from '@/components/notes/NoteForm'
import { SearchFilters } from '@/components/notes/SearchFilters'
import { StatsCard } from '@/components/notes/StatsCard'
import { ViewModeToggle } from '@/components/notes/ViewModeToggle'
import { EmptyState } from '@/components/ui/EmptyState'
import { SkeletonCard } from '@/components/ui/Skeleton'
import { useNotes } from '@/store/notes-store'
import { useKeyboardShortcut } from '@/hooks/useKeyboard'

const container = {
  hidden: { opacity: 0 },
  show: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1
    }
  }
}

const item = {
  hidden: { opacity: 0, y: 20 },
  show: { opacity: 1, y: 0 }
}

export default function HomePage() {
  const {
    filteredNotes,
    categories,
    stats,
    isLoading,
    showForm,
    editingNote,
    isFormLoading,
    loadInitialData,
    createNote,
    updateNote,
    deleteNote,
    setShowForm,
    setEditingNote,
  } = useNotes()

  useEffect(() => {
    loadInitialData()
  }, [loadInitialData])

  // Atajos de teclado
  useKeyboardShortcut(['ctrl', 'n'], () => {
    setEditingNote(null)
    setShowForm(true)
  })

  const handleCreateNote = () => {
    setEditingNote(null)
    setShowForm(true)
  }

  const handleEditNote = (note: any) => {
    setEditingNote(note)
    setShowForm(true)
  }

  const handleFormSubmit = async (formData: any) => {
    if (editingNote) {
      await updateNote(editingNote.id, formData)
    } else {
      await createNote(formData)
    }
  }

  const handleCloseForm = () => {
    if (!isFormLoading) {
      setShowForm(false)
      setEditingNote(null)
    }
  }

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50">
        <Header />
        <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          {/* Stats skeleton */}
          <div className="bg-white rounded-2xl shadow-soft p-6 mb-8 animate-pulse">
            <div className="h-6 bg-gray-200 rounded w-32 mb-4"></div>
            <div className="grid grid-cols-4 gap-4">
              {[...Array(4)].map((_, i) => (
                <div key={i} className="text-center">
                  <div className="h-8 bg-gray-200 rounded w-12 mx-auto mb-2"></div>
                  <div className="h-4 bg-gray-200 rounded w-16 mx-auto"></div>
                </div>
              ))}
            </div>
          </div>

          {/* Filters skeleton */}
          <div className="bg-white rounded-2xl shadow-soft p-6 mb-8 animate-pulse">
            <div className="h-12 bg-gray-200 rounded-xl mb-4"></div>
            <div className="grid grid-cols-2 gap-4">
              <div className="h-10 bg-gray-200 rounded-lg"></div>
              <div className="h-10 bg-gray-200 rounded-lg"></div>
            </div>
          </div>

          {/* Notes grid skeleton */}
          <div className="grid-responsive gap-6">
            {[...Array(8)].map((_, i) => (
              <SkeletonCard key={i} />
            ))}
          </div>
        </main>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50">
      <Header />
      
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Título y estadísticas */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center mb-8"
        >
          <h1 className="text-4xl font-bold text-gray-900 mb-4 text-shadow">
            📝 Sistema de Gestión de Notas
          </h1>
          <p className="text-xl text-gray-600 mb-8">
            Organiza tus ideas de manera eficiente
          </p>
          
          <StatsCard stats={stats} />
        </motion.div>

        {/* Filtros y controles */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="mb-8"
        >
          <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-6">
            <div className="flex items-center space-x-4">
              <h2 className="text-lg font-semibold text-gray-800">
                Mis Notas ({filteredNotes.length})
              </h2>
              <ViewModeToggle />
            </div>
            
            <div className="flex items-center space-x-2">
              <span className="text-sm text-gray-500 hidden sm:inline">
                Ctrl+N para nueva nota
              </span>
            </div>
          </div>
          
          <SearchFilters />
        </motion.div>

        {/* Contenido principal */}
        {filteredNotes.length === 0 ? (
          <EmptyState
            icon={FileText}
            title="No hay notas disponibles"
            description="¡Crea tu primera nota para comenzar a organizar tus ideas!"
            actionLabel="Crear primera nota"
            onAction={handleCreateNote}
          />
        ) : (
          <motion.div
            variants={container}
            initial="hidden"
            animate="show"
            className="grid-responsive gap-6"
          >
            {filteredNotes.map((note, index) => (
              <motion.div key={note.id} variants={item}>
                <NoteCard
                  note={note}
                  index={index}
                  onEdit={handleEditNote}
                  onDelete={deleteNote}
                />
              </motion.div>
            ))}
          </motion.div>
        )}

        {/* Botón flotante para móviles */}
        <motion.button
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          transition={{ delay: 0.5 }}
          onClick={handleCreateNote}
          className="fixed bottom-6 right-6 bg-gradient-to-r from-primary-500 to-primary-600 text-white p-4 rounded-full shadow-large hover:shadow-glow-lg transition-all duration-300 sm:hidden z-40"
          whileHover={{ scale: 1.1 }}
          whileTap={{ scale: 0.95 }}
        >
          <Plus size={24} />
        </motion.button>

        {/* Formulario modal */}
        <NoteForm
          note={editingNote}
          categories={categories}
          isOpen={showForm}
          onClose={handleCloseForm}
          onSubmit={handleFormSubmit}
          isLoading={isFormLoading}
        />
      </main>
    </div>
  )
}