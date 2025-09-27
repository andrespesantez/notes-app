// src/components/notes/ViewModeToggle.tsx
'use client'

import { useState } from 'react'
import { Grid3X3, List, LayoutGrid } from 'lucide-react'
import { Button } from '@/components/ui/Button'
import { useLocalStorage } from '@/hooks/useLocalStorage'

type ViewMode = 'grid' | 'list' | 'compact'

const ViewModeToggle = () => {
  const [viewMode, setViewMode] = useLocalStorage<ViewMode>('notes-view-mode', 'grid')

  const viewModes = [
    { id: 'grid' as const, icon: LayoutGrid, label: 'Grid' },
    { id: 'list' as const, icon: List, label: 'Lista' },
    { id: 'compact' as const, icon: Grid3X3, label: 'Compacto' },
  ]

  return (
    <div className="flex bg-gray-100 rounded-lg p-1">
      {viewModes.map((mode) => {
        const Icon = mode.icon
        return (
          <Button
            key={mode.id}
            variant={viewMode === mode.id ? 'primary' : 'ghost'}
            size="sm"
            onClick={() => setViewMode(mode.id)}
            className="px-3 py-2"
          >
            <Icon size={16} />
            <span className="ml-2 hidden sm:inline">{mode.label}</span>
          </Button>
        )
      })}
    </div>
  )
}

export { ViewModeToggle }