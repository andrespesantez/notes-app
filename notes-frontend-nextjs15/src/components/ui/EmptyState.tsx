import { motion } from 'framer-motion'
import { LucideIcon } from 'lucide-react'
import { Button } from './Button'

interface EmptyStateProps {
  icon: LucideIcon
  title: string
  description: string
  actionLabel?: string
  onAction?: () => void
  className?: string
}

const EmptyState = ({
  icon: Icon,
  title,
  description,
  actionLabel,
  onAction,
  className
}: EmptyStateProps) => {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className={`text-center py-16 px-4 ${className}`}
    >
      <div className="bg-gray-100 rounded-full p-6 w-24 h-24 mx-auto mb-6 flex items-center justify-center">
        <Icon size={32} className="text-gray-400" />
      </div>
      
      <h3 className="text-2xl font-semibold text-gray-800 mb-2 text-balance">
        {title}
      </h3>
      
      <p className="text-gray-600 mb-8 max-w-md mx-auto text-balance">
        {description}
      </p>
      
      {actionLabel && onAction && (
        <Button onClick={onAction} size="lg">
          {actionLabel}
        </Button>
      )}
    </motion.div>
  )
}

export { EmptyState }