"use client"

import { createContext, useContext, useEffect, useState } from "react"
import { NotesProvider } from "@/store/notes-store"

interface AppContextType {
  mounted: boolean
}

const AppContext = createContext<AppContextType>({ mounted: false })

export function Providers({ children }: { children: React.ReactNode }) {
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  return (
    <AppContext.Provider value={{ mounted }}>
      <NotesProvider>
        {children}
      </NotesProvider>
    </AppContext.Provider>
  )
}

export const useApp = () => useContext(AppContext)
