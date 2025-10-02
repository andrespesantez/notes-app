// src/components/notes/SearchFilters.tsx
'use client'

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Search, Filter, X, ChevronDown } from 'lucide-react'
import { Input } from '@/components/ui/Input'
import { Button } from '@/components/ui/Button'
import { useNotes } from '@/store/notes-store'
import { useDebounce } from '@/hooks/useDebounce'
import { useEffect } from 'react'

const SearchFilters = () => {
  const {
    searchKeyword,
    selectedCategory,
    selectedPriority,
    categories,
    setSearchKeyword,
    setSelectedCategory,
    setSelectedPriority,
    filterNotes,
  } = useNotes()

  const [searchTerm, setSearchTerm] = useState(searchKeyword)
  const [showFilters, setShowFilters] = useState(false)
  const debouncedSearch = useDebounce(searchTerm, 300)

  useEffect(() => {
    setSearchKeyword(debouncedSearch)
  }, [debouncedSearch, setSearchKeyword])

  useEffect(() => {
    filterNotes()
  }, [searchKeyword, selectedCategory, selectedPriority, filterNotes])

  const clearAllFilters = () => {
    setSearchTerm('')
    setSearchKeyword('')
    setSelectedCategory('')
    setSelectedPriority('')
  }

  const hasActiveFilters = searchKeyword || selectedCategory || selectedPriority

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="bg-white/80 backdrop-blur-lg rounded-2xl shadow-soft border border-gray-100 p-6"
    >
      {/* Búsqueda principal */}
      <div className="mb-4">
        <Input
          placeholder="🔍 Buscar en todas tus notas..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          leftIcon={<Search className="h-4 w-4 text-gray-400" />}
          className="bg-white/70"
        />
      </div>

      {/* Toggle y clear filters */}
      <div className="flex justify-between items-center mb-4">
        <Button
          variant="ghost"
          size="sm"
          onClick={() => setShowFilters(!showFilters)}
          leftIcon={<Filter className="h-4 w-4" />}
          rightIcon={
            <ChevronDown 
              className={`h-4 w-4 transition-transform ${showFilters ? 'rotate-180' : ''}`} 
            />
          }
        >
          Filtros avanzados
        </Button>

        <AnimatePresence>
          {hasActiveFilters && (
            <motion.div
              initial={{ opacity: 0, x: 10 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 10 }}
            >
              <Button
                variant="ghost"
                size="sm"
                onClick={clearAllFilters}
                leftIcon={<X className="h-4 w-4" />}
                className="text-red-600 hover:text-red-700 hover:bg-red-50"
              >
                Limpiar filtros
              </Button>
            </motion.div>
          )}
        </AnimatePresence>
      </div>

      {/* Filtros expandibles */}
      <AnimatePresence>
        {showFilters && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            exit={{ opacity: 0, height: 0 }}
            transition={{ duration: 0.2 }}
            className="border-t border-gray-200 pt-4"
          >
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  📁 Categoría
                </label>
                <select
                  value={selectedCategory}
                  onChange={(e) => setSelectedCategory(e.target.value)}
                  className="select"
                >
                  <option value="">Todas las categorías</option>
                  {categories.map((category: string) => (
                    <option key={category} value={category}>{category}</option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  🏷️ Prioridad
                </label>
                <select
                  value={selectedPriority}
                  onChange={(e) => setSelectedPriority(e.target.value)}
                  className="select"
                >
                  <option value="">Todas las prioridades</option>
                  <option value="HIGH">🔴 Alta</option>
                  <option value="MEDIUM">🟡 Media</option>
                  <option value="LOW">🟢 Baja</option>
                </select>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  )
}

export { SearchFilters }