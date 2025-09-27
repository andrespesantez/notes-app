import { useEffect } from 'react';

export const useKeyboard = (key: string, callback: () => void) => {
    useEffect(() => {
        const handleKeyPress = (event: KeyboardEvent) => {
            if (event.key === key) {
                callback();
            }
        };

        window.addEventListener('keydown', handleKeyPress);
        return () => {
            window.removeEventListener('keydown', handleKeyPress);
        };
    }, [key, callback]);
};

export const useKeyboardShortcut = (keys: string[], callback: () => void) => {
    useEffect(() => {
        const handleKeyPress = (event: KeyboardEvent) => {
            if (keys.every(key => event.key === key)) {
                callback();
            }
        };

        window.addEventListener('keydown', handleKeyPress);
        return () => {
            window.removeEventListener('keydown', handleKeyPress);
        };
    }, [keys, callback]);
};