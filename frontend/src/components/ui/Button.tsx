'use client'

import { forwardRef } from 'react'
import { cn } from '@/lib/utils'
import { motion } from 'framer-motion'
import { Loader2 } from 'lucide-react'

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'success' | 'danger' | 'ghost' | 'outline'
  size?: 'sm' | 'md' | 'lg'
  isLoading?: boolean
  leftIcon?: React.ReactNode
  rightIcon?: React.ReactNode
  animate?: boolean
}

const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ 
    className, 
    variant = 'primary', 
    size = 'md', 
    isLoading, 
    leftIcon, 
    rightIcon, 
    animate = true,
    children, 
    disabled,
    ...props 
  }, ref) => {
    const baseClasses = 'btn focus-visible'
    
    const variants = {
      primary: 'btn-primary',
      secondary: 'btn-secondary',
      success: 'btn-success',
      danger: 'btn-danger',
      ghost: 'btn-ghost',
      outline: 'border-2 border-primary-500 text-primary-500 hover:bg-primary-50',
    }

    const sizes = {
      sm: 'btn-sm',
      md: 'btn-md', 
      lg: 'btn-lg',
    }

    const MotionWrapper = animate ? motion.button : 'button'

    return (
      <MotionWrapper
        ref={ref}
        className={cn(
          baseClasses,
          variants[variant],
          sizes[size],
          className
        )}
        disabled={disabled || isLoading}
        whileTap={animate ? { scale: 0.95 } : undefined}
        whileHover={animate ? { scale: 1.02 } : undefined}
        {...props}
      >
        {isLoading && <Loader2 className="w-4 h-4 mr-2 animate-spin" />}
        {!isLoading && leftIcon && <span className="mr-2">{leftIcon}</span>}
        {children}
        {!isLoading && rightIcon && <span className="ml-2">{rightIcon}</span>}
      </MotionWrapper>
    )
  }
)

Button.displayName = 'Button'

export { Button }