'use client'

import { memo } from 'react'
import { motion } from 'framer-motion'
import { Edit3, Trash2, Clock, Folder } from 'lucide-react'
import { Note } from '@/types'
import { Badge } from '@/components/ui/Badge'
import { Button } from '@/components/ui/Button'
import { getPriorityColor, formatDate, truncateText, getCategoryIcon } from '@/lib/utils'

interface NoteCardProps {
  note: Note
  index: number
  onEdit: (note: Note) => void
  onDelete: (id: number) => void
}

const NoteCard = memo(({ note, index, onEdit, onDelete }: NoteCardProps) => {
  const priorityColors = getPriorityColor(note.priority)

  const handleDelete = () => {
    if (window.confirm('¿Estás seguro de que quieres eliminar esta nota?')) {
      onDelete(note.id)
    }
  }

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3, delay: index * 0.05 }}
      whileHover={{ y: -2 }}
      className="card-interactive p-6 group relative overflow-hidden"
    >
      {/* Indicador de prioridad */}
      <div 
        className={`absolute top-0 left-0 w-1 h-full ${priorityColors.bg} rounded-l-2xl`}
      />
      
      <div className="ml-2">
        {/* Header */}
        <div className="flex justify-between items-start mb-4">
          <h3 className="text-lg font-semibold text-gray-900 flex-1 mr-2 leading-tight line-clamp-2">
            {note.title}
          </h3>
          <div className="flex space-x-1 opacity-0 group-hover:opacity-100 transition-opacity">
            <Button
              variant="ghost"
              size="sm"
              onClick={() => onEdit(note)}
              className="p-2 h-8 w-8"
            >
              <Edit3 size={14} />
            </Button>
            <Button
              variant="ghost"
              size="sm"
              onClick={handleDelete}
              className="p-2 h-8 w-8 text-red-500 hover:text-red-700 hover:bg-red-50"
            >
              <Trash2 size={14} />
            </Button>
          </div>
        </div>

        {/* Contenido */}
        {note.content && (
          <p className="text-gray-600 mb-4 leading-relaxed line-clamp-3">
            {truncateText(note.content, 120)}
          </p>
        )}

        {/* Footer */}
        <div className="flex flex-wrap items-center gap-2 mb-3">
          <Badge variant="priority" priority={note.priority} size="sm">
            {note.priority === 'HIGH' ? '🔴 Alta' : 
             note.priority === 'MEDIUM' ? '🟡 Media' : '🟢 Baja'}
          </Badge>
          
          <Badge variant="category" size="sm">
            <Folder className="w-3 h-3 mr-1" />
            {note.category}
          </Badge>
        </div>

        {/* Fecha */}
        <div className="flex items-center text-xs text-gray-500">
          <Clock className="w-3 h-3 mr-1" />
          {formatDate(note.updatedAt)}
        </div>
      </div>
    </motion.div>
  )
})

NoteCard.displayName = 'NoteCard'

export { NoteCard }