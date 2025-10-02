import { useEffect, useRef, useState, RefObject } from 'react';

const useIntersectionObserver = (options?: IntersectionObserverInit): [RefObject<HTMLDivElement>, boolean] => {
    const [isIntersecting, setIsIntersecting] = useState(false);
    const ref = useRef<HTMLDivElement>(null);

    useEffect(() => {
        const observer = new IntersectionObserver(([entry]) => {
            if (entry) {
                setIsIntersecting(entry.isIntersecting);
            }
        }, options);

        const currentRef = ref.current;
        if (currentRef) {
            observer.observe(currentRef);
        }

        return () => {
            if (currentRef) {
                observer.unobserve(currentRef);
            }
        };
    }, [options]);

    return [ref, isIntersecting];
};

export default useIntersectionObserver;
