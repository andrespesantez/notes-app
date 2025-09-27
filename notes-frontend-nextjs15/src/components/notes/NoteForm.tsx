'use client'

import { useState, useEffect } from 'react'
import { motion } from 'framer-motion'
import { Save, X } from 'lucide-react'
import { Note, NoteFormData } from '@/types'
import { Modal } from '@/components/ui/Modal'
import { Input } from '@/components/ui/Input'
import { Button } from '@/components/ui/Button'

interface NoteFormProps {
  note: Note | null
  categories: string[]
  isOpen: boolean
  onClose: () => void
  onSubmit: (data: NoteFormData) => Promise<void>
  isLoading: boolean
}

const NoteForm = ({ 
  note, 
  categories, 
  isOpen, 
  onClose, 
  onSubmit, 
  isLoading 
}: NoteFormProps) => {
  const [formData, setFormData] = useState<NoteFormData>({
    title: '',
    content: '',
    category: 'General',
    priority: 'MEDIUM',
  })

  const [errors, setErrors] = useState<Partial<NoteFormData>>({})

  useEffect(() => {
    if (note) {
      setFormData({
        title: note.title,
        content: note.content || '',
        category: note.category,
        priority: note.priority,
      })
    } else {
      setFormData({
        title: '',
        content: '',
        category: 'General',
        priority: 'MEDIUM',
      })
    }
    setErrors({})
  }, [note, isOpen])

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value } = e.target
    setFormData(prev => ({ ...prev, [name]: value }))
    
    if (errors[name as keyof NoteFormData]) {
      setErrors(prev => ({ ...prev, [name]: '' }))
    }
  }

  const validateForm = (): boolean => {
    const newErrors: Partial<NoteFormData> = {}

    if (!formData.title.trim()) {
      newErrors.title = 'El título es obligatorio'
    } else if (formData.title.length > 255) {
      newErrors.title = 'El título no puede exceder 255 caracteres'
    }

    if (!formData.category.trim()) {
      newErrors.category = 'La categoría es obligatoria'
    }

    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!validateForm()) return

    try {
      await onSubmit({
        ...formData,
        title: formData.title.trim(),
        content: formData.content.trim(),
        category: formData.category.trim(),
      })
    } catch (error) {
      console.error('Error submitting form:', error)
    }
  }

  return (
    <Modal
      isOpen={isOpen}
      onClose={onClose}
      title={note ? 'Editar Nota' : 'Nueva Nota'}
      size="lg"
      closeOnOutsideClick={!isLoading}
      showCloseButton={!isLoading}
    >
      <motion.form
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        onSubmit={handleSubmit}
        className="space-y-6"
      >
        <Input
          label="Título *"
          name="title"
          value={formData.title}
          onChange={handleChange}
          error={errors.title}
          placeholder="Ingresa el título de tu nota"
          disabled={isLoading}
          maxLength={255}
        />

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Contenido
          </label>
          <textarea
            name="content"
            rows={6}
            value={formData.content}
            onChange={handleChange}
            className="textarea"
            placeholder="Describe el contenido de tu nota..."
            disabled={isLoading}
          />
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <Input
            label="Categoría *"
            name="category"
            value={formData.category}
            onChange={handleChange}
            error={errors.category}
            placeholder="Ej: Trabajo, Personal, Estudios"
            disabled={isLoading}
            list="categories"
          />

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Prioridad
            </label>
            <select
              name="priority"
              value={formData.priority}
              onChange={handleChange}
              className="select"
              disabled={isLoading}
            >
              <option value="LOW">🟢 Baja</option>
              <option value="MEDIUM">🟡 Media</option>
              <option value="HIGH">🔴 Alta</option>
            </select>
          </div>
        </div>

        <datalist id="categories">
          {categories.map(cat => (
            <option key={cat} value={cat} />
          ))}
        </datalist>

        <div className="flex justify-end space-x-3 pt-6 border-t">
          <Button
            type="button"
            variant="secondary"
            onClick={onClose}
            disabled={isLoading}
          >
            Cancelar
          </Button>
          <Button
            type="submit"
            isLoading={isLoading}
            leftIcon={<Save className="w-4 h-4" />}
          >
            {note ? 'Actualizar' : 'Crear'}
          </Button>
        </div>
      </motion.form>
    </Modal>
  )
}

export { NoteForm }