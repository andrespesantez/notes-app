// src/components/notes/StatsCard.tsx
'use client'

import { motion } from 'framer-motion'
import { BarChart3, TrendingUp, Clock, Star } from 'lucide-react'
import { NoteStats } from '@/types'

interface StatsCardProps {
  stats: NoteStats
}

const StatsCard = ({ stats }: StatsCardProps) => {
  const statItems = [
    {
      label: 'Total',
      value: stats.total,
      icon: BarChart3,
      color: 'text-blue-600',
      bg: 'bg-blue-100',
    },
    {
      label: 'Alta Prioridad',
      value: stats.high,
      icon: Star,
      color: 'text-red-600',
      bg: 'bg-red-100',
    },
    {
      label: 'Media Prioridad',
      value: stats.medium,
      icon: TrendingUp,
      color: 'text-yellow-600',
      bg: 'bg-yellow-100',
    },
    {
      label: 'Baja Prioridad',
      value: stats.low,
      icon: Clock,
      color: 'text-green-600',
      bg: 'bg-green-100',
    },
  ]

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="bg-gradient-to-r from-primary-500 to-primary-600 text-white rounded-2xl shadow-large p-6 mb-8"
    >
      <div className="flex items-center justify-between mb-6">
        <h3 className="text-lg font-semibold flex items-center">
          <BarChart3 className="mr-2" size={20} />
          Estadísticas
        </h3>
      </div>
      
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
        {statItems.map((item, index) => {
          const Icon = item.icon
          return (
            <motion.div
              key={item.label}
              initial={{ opacity: 0, scale: 0.8 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: index * 0.1 }}
              className="text-center"
            >
              <div className={`${item.bg} ${item.color} rounded-xl p-3 mb-2 inline-flex items-center justify-center`}>
                <Icon size={20} />
              </div>
              <div className="text-2xl font-bold text-white">{item.value}</div>
              <div className="text-sm opacity-90">{item.label}</div>
            </motion.div>
          )
        })}
      </div>
    </motion.div>
  )
}

export { StatsCard }