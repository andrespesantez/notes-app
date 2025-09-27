'use client'

import { cn } from '@/lib/utils'
import { Note } from '@/types'

interface BadgeProps {
  variant?: 'default' | 'priority' | 'category' | 'success' | 'warning' | 'danger'
  priority?: Note['priority']
  size?: 'sm' | 'md' | 'lg'
  children: React.ReactNode
  className?: string
}

const Badge = ({ variant = 'default', priority, size = 'md', children, className }: BadgeProps) => {
  const baseClasses = 'badge'
  
  const variants = {
    default: 'bg-gray-100 text-gray-800 border-gray-200',
    priority: priority === 'HIGH' ? 'badge-priority-high' : 
              priority === 'MEDIUM' ? 'badge-priority-medium' : 
              'badge-priority-low',
    category: 'bg-blue-100 text-blue-800 border-blue-200',
    success: 'bg-green-100 text-green-800 border-green-200',
    warning: 'bg-yellow-100 text-yellow-800 border-yellow-200',
    danger: 'bg-red-100 text-red-800 border-red-200',
  }

  const sizes = {
    sm: 'px-2 py-0.5 text-xs',
    md: 'px-3 py-1 text-xs',
    lg: 'px-4 py-1.5 text-sm',
  }

  return (
    <span className={cn(baseClasses, variants[variant], sizes[size], className)}>
      {children}
    </span>
  )
}

export { Badge }