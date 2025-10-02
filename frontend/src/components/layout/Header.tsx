'use client'

import { motion } from 'framer-motion'
import { Plus, RefreshCw, Search } from 'lucide-react'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'
import { useNotes } from '@/store/notes-store'
import { useDebounce } from '@/hooks/useDebounce'
import { useEffect, useState } from 'react'

const Header = () => {
  const {
    searchKeyword,
    setSearchKeyword,
    setShowForm,
    setEditingNote,
    refreshData,
    isLoading,
  } = useNotes()

  const [searchTerm, setSearchTerm] = useState(searchKeyword)
  const [isRefreshing, setIsRefreshing] = useState(false)
  const debouncedSearch = useDebounce(searchTerm, 300)

  useEffect(() => {
    setSearchKeyword(debouncedSearch)
  }, [debouncedSearch, setSearchKeyword])

  const handleNewNote = () => {
    setEditingNote(null)
    setShowForm(true)
  }

  const handleRefresh = async () => {
    setIsRefreshing(true)
    await refreshData()
    setIsRefreshing(false)
  }

  return (
    <motion.header
      initial={{ opacity: 0, y: -20 }}
      animate={{ opacity: 1, y: 0 }}
      className="bg-white/80 backdrop-blur-lg border-b border-gray-200 sticky top-0 z-40"
    >
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
          <motion.div
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            className="flex items-center space-x-3"
          >
            <div className="text-2xl">📝</div>
            <h1 className="text-xl font-bold text-gray-900 hidden sm:block">
              Sistema de Notas
            </h1>
          </motion.div>

          {/* Búsqueda */}
          <div className="flex-1 max-w-lg mx-4">
            <Input
              placeholder="🔍 Buscar notas..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              leftIcon={<Search className="h-4 w-4 text-gray-400" />}
              className="bg-white/50"
            />
          </div>

          {/* Acciones */}
          <div className="flex items-center space-x-2">
            <Button
              variant="ghost"
              size="sm"
              onClick={handleRefresh}
              disabled={isRefreshing}
              leftIcon={
                <RefreshCw 
                  className={`h-4 w-4 ${isRefreshing ? 'animate-spin' : ''}`} 
                />
              }
              className="hidden sm:flex"
            >
              {isRefreshing ? 'Actualizando...' : 'Actualizar'}
            </Button>

            <Button
              onClick={handleNewNote}
              size="sm"
              leftIcon={<Plus className="h-4 w-4" />}
              disabled={isLoading}
            >
              <span className="hidden sm:inline">Nueva Nota</span>
            </Button>
          </div>
        </div>
      </div>
    </motion.header>
  )
}

export { Header }