import { useEffect, DependencyList } from "react"

export function useKeyboard(key: string, callback: () => void, deps: DependencyList = []) {
  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === key) {
        event.preventDefault()
        callback()
      }
    }

    document.addEventListener("keydown", handleKeyDown)
    return () => document.removeEventListener("keydown", handleKeyDown)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [key, callback, ...deps])
}

export function useKeyboardShortcut(
  keys: string[],
  callback: () => void,
  deps: DependencyList = []
) {
  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      const pressedKeys: string[] = []
      
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
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [keys, callback, ...deps])
}