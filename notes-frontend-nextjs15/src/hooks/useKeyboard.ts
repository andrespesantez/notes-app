import { useEffect } from "react"

export function useKeyboard(key: string, callback: () => void, deps: any[] = []) {
  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === key) {
        event.preventDefault()
        callback()
      }
    }

    document.addEventListener("keydown", handleKeyDown)
    return () => document.removeEventListener("keydown", handleKeyDown)
  }, [key, callback, ...deps])
}

export function useKeyboardShortcut(
  keys: string[],
  callback: () => void,
  deps: any[] = []
) {
  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      const pressedKeys = []
      
      if (event.ctrlKey) pressedKeys.push("ctrl")
      if (event.altKey) pressedKeys.push("alt")
      if (event.shiftKey) pressedKeys.push("shift")
      if (event.metaKey) pressedKeys.push("meta")
      
      pressedKeys.push(event.key.toLowerCase())
      
      const keysMatch = keys.every(key => 
        pressedKeys.includes(key.toLowerCase())
      ) && keys.length === pressedKeys.length

      if (keysMatch) {
        event.preventDefault()
        callback()
      }
    }

    document.addEventListener("keydown", handleKeyDown)
    return () => document.removeEventListener("keydown", handleKeyDown)
  }, [keys, callback, ...deps])
}
