#!/bin/bash
# =====================================================
# 📱 GENERADOR FRONTEND - Next.js 15 + TypeScript
# Sistema de Gestión de Notas - Frontend Completo
# =====================================================

set -e

echo "🚀 Generando Frontend Next.js 15..."
echo "📦 Estructura completa con TypeScript, Tailwind CSS y componentes modernos"
echo ""

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Función para crear archivos
create_file() {
    local filepath="$1"
    local content="$2"
    mkdir -p "$(dirname "$filepath")"
    echo -e "$content" > "$filepath"
    echo -e "${GREEN}✅ $filepath${NC}"
}

# Crear directorio
PROJECT_DIR="notes-frontend-nextjs15"
if [ -d "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}⚠️  $PROJECT_DIR existe. ¿Sobrescribir? (y/n)${NC}"
    read -r response
    [[ "$response" != "y" ]] && exit 1
    rm -rf "$PROJECT_DIR"
fi

mkdir "$PROJECT_DIR" && cd "$PROJECT_DIR"

echo -e "${BLUE}📁 Creando estructura...${NC}"

# Crear estructura completa
mkdir -p src/{app,components/{ui,layout,notes},hooks,store,lib,types}
mkdir -p public

echo -e "${BLUE}📄 Generando archivos...${NC}"

# =====================================================
# ROOT FILES
# =====================================================

create_file "package.json" '{
  "name": "notes-frontend-nextjs15",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "lint:fix": "next lint --fix",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "next": "^15.0.3",
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "axios": "^1.6.2",
    "lucide-react": "^0.294.0",
    "@headlessui/react": "^2.0.4",
    "clsx": "^2.1.0",
    "framer-motion": "^11.0.3",
    "react-hot-toast": "^2.4.1",
    "use-debounce": "^10.0.0",
    "zustand": "^4.4.7",
    "@tailwindcss/forms": "^0.5.7",
    "@tailwindcss/typography": "^0.5.10"
  },
  "devDependencies": {
    "@types/node": "^20.10.0",
    "@types/react": "^18.2.43",
    "@types/react-dom": "^18.2.17",
    "autoprefixer": "^10.4.16",
    "postcss": "^8.4.32",
    "tailwindcss": "^3.4.0",
    "typescript": "^5.3.3",
    "eslint": "^8.57.0",
    "eslint-config-next": "^15.0.3",
    "@typescript-eslint/eslint-plugin": "^6.13.1",
    "@typescript-eslint/parser": "^6.13.1",
    "cssnano": "^6.0.2"
  },
  "engines": {
    "node": ">=18.17.0",
    "npm": ">=9.0.0"
  }
}'

create_file "next.config.js" '/** @type {import("next").NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  output: "standalone",
  
  // Configuración experimental para Next.js 15
  experimental: {
    optimizePackageImports: ["lucide-react", "@headlessui/react"],
    turbo: {
      rules: {
        "*.svg": {
          loaders: ["@svgr/webpack"],
          as: "*.js",
        },
      },
    },
  },
  
  // Configuración para el proxy API
  async rewrites() {
    return [
      {
        source: "/api/:path*",
        destination: `${process.env.NEXT_PUBLIC_API_URL || "http://backend-api:8080/api"}/:path*`,
      },
    ]
  },
  
  // Variables de entorno públicas
  env: {
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL || "http://localhost/api",
    NEXT_PUBLIC_APP_VERSION: process.env.npm_package_version || "1.0.0",
  },
  
  // Configuración de imágenes optimizada
  images: {
    formats: ["image/webp", "image/avif"],
    deviceSizes: [640, 768, 1024, 1280, 1600],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
    minimumCacheTTL: 60,
    dangerouslyAllowSVG: true,
    contentDispositionType: "attachment",
    contentSecurityPolicy: "default-src '"'"'self'"'"'; script-src '"'"'none'"'"'; sandbox;",
  },
  
  // Configuración de compilación
  compiler: {
    removeConsole: process.env.NODE_ENV === "production",
  },
  
  // Headers de seguridad mejorados
  async headers() {
    return [
      {
        source: "/:path*",
        headers: [
          {
            key: "X-Frame-Options",
            value: "DENY",
          },
          {
            key: "X-Content-Type-Options",
            value: "nosniff",
          },
          {
            key: "Referrer-Policy",
            value: "origin-when-cross-origin",
          },
          {
            key: "X-XSS-Protection",
            value: "1; mode=block",
          },
          {
            key: "Permissions-Policy",
            value: "camera=(), microphone=(), geolocation=(), browsing-topics=()",
          },
        ],
      },
    ]
  },
  
  // Configuración de webpack personalizada
  webpack: (config, { dev, isServer }) => {
    // Optimizaciones para producción
    if (!dev && !isServer) {
      config.optimization.splitChunks.chunks = "all";
    }
    
    return config;
  },
}

module.exports = nextConfig'

create_file "tailwind.config.js" '/** @type {import("tailwindcss").Config} */
module.exports = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        primary: {
          50: "#f0f4ff",
          100: "#e0e7ff",
          200: "#c7d2fe",
          300: "#a5b4fc",
          400: "#818cf8",
          500: "#6366f1",
          600: "#4f46e5",
          700: "#4338ca",
          800: "#3730a3",
          900: "#312e81",
          950: "#1e1b4b",
        },
        priority: {
          low: "#10b981",
          medium: "#f59e0b",
          high: "#ef4444",
        },
        surface: {
          50: "#f8fafc",
          100: "#f1f5f9",
          200: "#e2e8f0",
          300: "#cbd5e1",
          400: "#94a3b8",
          500: "#64748b",
          600: "#475569",
          700: "#334155",
          800: "#1e293b",
          900: "#0f172a",
        }
      },
      fontFamily: {
        sans: ["var(--font-inter)", "system-ui", "sans-serif"],
        mono: ["var(--font-fira-code)", "Consolas", "Monaco", "monospace"],
      },
      animation: {
        "fade-in": "fadeIn 0.5s ease-in-out",
        "slide-up": "slideUp 0.3s ease-out",
        "slide-down": "slideDown 0.3s ease-out",
        "slide-in-right": "slideInRight 0.3s ease-out",
        "bounce-in": "bounceIn 0.6s ease-out",
        "pulse-soft": "pulseSoft 2s ease-in-out infinite",
        "float": "float 3s ease-in-out infinite",
        "shimmer": "shimmer 2s linear infinite",
      },
      keyframes: {
        fadeIn: {
          "0%": { opacity: "0", transform: "translateY(10px)" },
          "100%": { opacity: "1", transform: "translateY(0)" },
        },
        slideUp: {
          "0%": { opacity: "0", transform: "translateY(20px)" },
          "100%": { opacity: "1", transform: "translateY(0)" },
        },
        slideDown: {
          "0%": { opacity: "0", transform: "translateY(-20px)" },
          "100%": { opacity: "1", transform: "translateY(0)" },
        },
        slideInRight: {
          "0%": { opacity: "0", transform: "translateX(20px)" },
          "100%": { opacity: "1", transform: "translateX(0)" },
        },
        bounceIn: {
          "0%": { opacity: "0", transform: "scale(0.3)" },
          "50%": { opacity: "1", transform: "scale(1.05)" },
          "70%": { transform: "scale(0.9)" },
          "100%": { opacity: "1", transform: "scale(1)" },
        },
        pulseSoft: {
          "0%, 100%": { opacity: "1" },
          "50%": { opacity: "0.8" },
        },
        float: {
          "0%, 100%": { transform: "translateY(0px)" },
          "50%": { transform: "translateY(-10px)" },
        },
        shimmer: {
          "0%": { backgroundPosition: "-200% 0" },
          "100%": { backgroundPosition: "200% 0" },
        },
      },
      backdropBlur: {
        xs: "2px",
      },
      boxShadow: {
        "soft": "0 2px 15px -3px rgba(0, 0, 0, 0.07), 0 10px 20px -2px rgba(0, 0, 0, 0.04)",
        "medium": "0 4px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04)",
        "large": "0 10px 40px -10px rgba(0, 0, 0, 0.1), 0 20px 25px -5px rgba(0, 0, 0, 0.04)",
        "glow": "0 0 20px rgba(99, 102, 241, 0.3)",
        "glow-lg": "0 0 40px rgba(99, 102, 241, 0.4)",
      },
      screens: {
        "xs": "475px",
        "3xl": "1600px",
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/typography"),
  ],
}'

create_file "tsconfig.json" '{
  "compilerOptions": {
    "lib": ["dom", "dom.iterable", "es2022"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "target": "es2022",
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@/components/*": ["./src/components/*"],
      "@/lib/*": ["./src/lib/*"],
      "@/types/*": ["./src/types/*"],
      "@/hooks/*": ["./src/hooks/*"],
      "@/store/*": ["./src/store/*"],
      "@/utils/*": ["./src/utils/*"]
    },
    "forceConsistentCasingInFileNames": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}'

create_file "postcss.config.js" 'module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
    ...(process.env.NODE_ENV === "production" && {
      cssnano: {
        preset: ["default", { discardComments: { removeAll: true } }],
      },
    }),
  },
}'

create_file ".eslintrc.json" '{
  "extends": ["next/core-web-vitals", "next/typescript"],
  "rules": {
    "@typescript-eslint/no-unused-vars": "warn",
    "@typescript-eslint/no-explicit-any": "warn",
    "react-hooks/exhaustive-deps": "warn"
  }
}'

create_file ".env.example" '# API Configuration
NEXT_PUBLIC_API_URL=http://localhost/api

# Environment
NODE_ENV=production

# Optional: For development
# NEXT_PUBLIC_API_URL=http://localhost:8080/api'

create_file "Dockerfile" '# Etapa de construcción
FROM node:18-alpine AS build

WORKDIR /app

# Copiar package.json y package-lock.json
COPY package*.json ./

# Instalar dependencias
RUN npm ci

# Copiar código fuente
COPY . .

# Construir la aplicación Next.js
RUN npm run build

# Etapa de producción
FROM node:18-alpine AS production

WORKDIR /app

# Crear usuario no-root
RUN addgroup -g 1001 -S nextjs && \\
    adduser -S nextjs -u 1001

# Copiar archivos necesarios
COPY --from=build /app/package*.json ./
COPY --from=build /app/.next ./.next
COPY --from=build /app/public ./public
COPY --from=build /app/next.config.js ./

# Instalar solo dependencias de producción
RUN npm ci --only=production && npm cache clean --force

# Cambiar al usuario no-root
USER nextjs

EXPOSE 3000

ENV NODE_ENV=production
ENV PORT=3000

CMD ["npm", "start"]'

# =====================================================
# TYPES
# =====================================================

create_file "src/types/index.ts" 'export interface Note {
  id: number;
  title: string;
  content: string;
  category: string;
  priority: "LOW" | "MEDIUM" | "HIGH";
  createdAt: string;
  updatedAt: string;
}

export interface ApiResponse<T> {
  status: "success" | "error";
  message: string;
  data: T;
}

export interface NoteStats {
  total: number;
  high: number;
  medium: number;
  low: number;
}

export interface NoteFormData {
  title: string;
  content: string;
  category: string;
  priority: Note["priority"];
}

export interface FilterOptions {
  keyword?: string;
  category?: string;
  priority?: Note["priority"];
}

export interface ViewMode {
  type: "grid" | "list" | "compact";
  columns: number;
}

export interface Theme {
  mode: "light" | "dark" | "system";
  primary: string;
  accent: string;
}'

# =====================================================
# APP FILES
# =====================================================

create_file "src/app/layout.tsx" 'import { Inter, Fira_Code } from "next/font/google"
import { Toaster } from "react-hot-toast"
import { Providers } from "./providers"
import "./globals.css"
import type { Metadata, Viewport } from "next"

const inter = Inter({
  subsets: ["latin"],
  display: "swap",
  variable: "--font-inter"
})

const firaCode = Fira_Code({
  subsets: ["latin"],
  display: "swap",
  variable: "--font-fira-code"
})

export const metadata: Metadata = {
  title: {
    template: "%s | Sistema de Notas",
    default: "📝 Sistema de Gestión de Notas"
  },
  description: "Aplicación completa para gestionar tus notas de forma eficiente con Next.js 15",
  keywords: ["notas", "productividad", "gestión", "organización", "next.js"],
  authors: [{ name: "Tu Nombre" }],
  creator: "Tu Nombre",
  publisher: "Tu Empresa",
  formatDetection: {
    email: false,
    address: false,
    telephone: false,
  },
  metadataBase: new URL(process.env.NEXT_PUBLIC_BASE_URL || "http://localhost:3000"),
  openGraph: {
    type: "website",
    siteName: "Sistema de Gestión de Notas",
    title: "📝 Sistema de Gestión de Notas",
    description: "Organiza tus ideas de manera eficiente",
    images: [
      {
        url: "/og-image.png",
        width: 1200,
        height: 630,
        alt: "Sistema de Gestión de Notas",
      }
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "📝 Sistema de Gestión de Notas",
    description: "Organiza tus ideas de manera eficiente",
    images: ["/og-image.png"],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      "max-video-preview": -1,
      "max-image-preview": "large",
      "max-snippet": -1,
    },
  },
  icons: {
    icon: "/favicon.ico",
    apple: "/apple-icon.png",
  },
}

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
  themeColor: [
    { media: "(prefers-color-scheme: light)", color: "#6366f1" },
    { media: "(prefers-color-scheme: dark)", color: "#4f46e5" },
  ],
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="es" className={`${inter.variable} ${firaCode.variable} h-full`} suppressHydrationWarning>
      <body className="h-full bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50 font-sans antialiased">
        <Providers>
          {children}
          <Toaster
            position="top-right"
            toastOptions={{
              duration: 4000,
              style: {
                background: "#fff",
                color: "#333",
                border: "1px solid #e2e8f0",
                borderRadius: "12px",
                boxShadow: "0 10px 25px -5px rgba(0, 0, 0, 0.1)",
                fontSize: "14px",
                maxWidth: "400px",
              },
              success: {
                iconTheme: {
                  primary: "#10b981",
                  secondary: "#fff",
                },
              },
              error: {
                iconTheme: {
                  primary: "#ef4444",
                  secondary: "#fff",
                },
              },
            }}
          />
        </Providers>
      </body>
    </html>
  )
}'

create_file "src/app/providers.tsx" '"use client"

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

export const useApp = () => useContext(AppContext)'

create_file "src/app/globals.css" '@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  html {
    font-feature-settings: "cv02", "cv03", "cv04", "cv11";
  }

  body {
    font-feature-settings: "rlig" 1, "calt" 1;
  }

  * {
    @apply border-border;
  }

  body {
    @apply bg-background text-foreground;
  }

  /* Scrollbar personalizado */
  ::-webkit-scrollbar {
    width: 6px;
    height: 6px;
  }

  ::-webkit-scrollbar-track {
    @apply bg-gray-100;
    border-radius: 3px;
  }

  ::-webkit-scrollbar-thumb {
    @apply bg-gray-300 hover:bg-gray-400;
    border-radius: 3px;
  }

  ::-webkit-scrollbar-thumb:hover {
    @apply bg-gray-400;
  }

  /* Dark mode scrollbar */
  .dark ::-webkit-scrollbar-track {
    @apply bg-gray-800;
  }

  .dark ::-webkit-scrollbar-thumb {
    @apply bg-gray-600 hover:bg-gray-500;
  }
}

@layer components {
  .btn {
    @apply inline-flex items-center justify-center rounded-xl font-semibold transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed select-none;
    @apply active:scale-95;
  }
  
  .btn-sm {
    @apply px-3 py-1.5 text-sm;
  }
  
  .btn-md {
    @apply px-4 py-2 text-sm;
  }
  
  .btn-lg {
    @apply px-6 py-3 text-base;
  }
  
  .btn-primary {
    @apply bg-gradient-to-r from-primary-500 to-primary-600 text-white hover:from-primary-600 hover:to-primary-700 focus:ring-primary-500/50 shadow-medium hover:shadow-large;
    @apply transform hover:-translate-y-0.5 active:translate-y-0;
  }
  
  .btn-secondary {
    @apply bg-white text-gray-700 border border-gray-300 hover:bg-gray-50 focus:ring-gray-500/50 shadow-soft hover:shadow-medium;
  }
  
  .btn-success {
    @apply bg-gradient-to-r from-emerald-500 to-emerald-600 text-white hover:from-emerald-600 hover:to-emerald-700 focus:ring-emerald-500/50;
  }
  
  .btn-danger {
    @apply bg-gradient-to-r from-red-500 to-red-600 text-white hover:from-red-600 hover:to-red-700 focus:ring-red-500/50;
  }
  
  .btn-ghost {
    @apply text-gray-600 hover:text-gray-900 hover:bg-gray-100 focus:ring-gray-500/50;
  }

  .input {
    @apply w-full px-4 py-3 bg-white border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500/50 focus:border-primary-500 transition-all duration-200 placeholder:text-gray-400;
    @apply shadow-soft focus:shadow-medium;
  }

  .textarea {
    @apply input resize-none;
  }

  .select {
    @apply input cursor-pointer;
  }

  .card {
    @apply bg-white rounded-2xl shadow-soft hover:shadow-medium transition-all duration-300;
    @apply border border-gray-100;
  }

  .card-interactive {
    @apply card hover:scale-[1.02] hover:-translate-y-1 cursor-pointer;
  }

  .badge {
    @apply inline-flex items-center px-3 py-1 rounded-full text-xs font-medium;
  }

  .badge-priority-high {
    @apply badge bg-red-100 text-red-800 border border-red-200;
  }

  .badge-priority-medium {
    @apply badge bg-yellow-100 text-yellow-800 border border-yellow-200;
  }

  .badge-priority-low {
    @apply badge bg-green-100 text-green-800 border border-green-200;
  }

  .shimmer {
    @apply bg-gradient-to-r from-gray-200 via-gray-300 to-gray-200;
    background-size: 200% 100%;
    animation: shimmer 1.5s infinite;
  }

  .glass {
    @apply bg-white/20 backdrop-blur-md border border-white/30;
  }

  .text-balance {
    text-wrap: balance;
  }

  .grid-responsive {
    @apply grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 2xl:grid-cols-5;
  }
}

@layer utilities {
  .text-shadow {
    text-shadow: 0 2px 4px rgba(0,0,0,0.1);
  }

  .text-shadow-lg {
    text-shadow: 0 4px 8px rgba(0,0,0,0.2);
  }

  .safe-area-top {
    padding-top: env(safe-area-inset-top);
  }

  .safe-area-bottom {
    padding-bottom: env(safe-area-inset-bottom);
  }

  .no-scrollbar {
    -ms-overflow-style: none;
    scrollbar-width: none;
  }

  .no-scrollbar::-webkit-scrollbar {
    display: none;
  }
}

/* Animaciones personalizadas */
@keyframes float {
  0%, 100% { transform: translateY(0px); }
  50% { transform: translateY(-10px); }
}

@keyframes pulse-ring {
  0% { transform: scale(0.33); }
  40%, 50% { opacity: 1; }
  100% { opacity: 0; transform: scale(1.33); }
}

/* Print styles */
@media print {
  .no-print {
    display: none !important;
  }
}

/* High contrast mode */
@media (prefers-contrast: high) {
  .btn {
    @apply border-2 border-current;
  }
}

/* Reduced motion */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}

/* Focus visible styles */
.focus-visible:focus-visible {
  @apply outline-none ring-2 ring-primary-500 ring-offset-2;
}

/* Custom selection */
::selection {
  @apply bg-primary-100 text-primary-900;
}'

echo -e "${BLUE}⚛️  Generando componentes React...${NC}"

# =====================================================
# LIBRARY FILES  
# =====================================================

create_file "src/lib/api.ts" 'import axios from "axios";
import { Note, ApiResponse, NoteStats, FilterOptions } from "@/types";

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost/api";

// Crear instancia de axios con configuración base
const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
  },
  timeout: 15000,
});

// Interceptors para logging y manejo de errores
api.interceptors.request.use(
  (config) => {
    if (process.env.NODE_ENV === "development") {
      console.log(`🌐 ${config.method?.toUpperCase()} ${config.url}`, config.data);
    }
    return config;
  },
  (error) => {
    console.error("Request error:", error);
    return Promise.reject(error);
  }
);

api.interceptors.response.use(
  (response) => {
    if (process.env.NODE_ENV === "development") {
      console.log(`✅ ${response.config.method?.toUpperCase()} ${response.config.url}`, response.data);
    }
    return response;
  },
  (error) => {
    console.error("Response error:", error);
    
    // Manejo específico de errores de red
    if (error.code === "ECONNABORTED") {
      throw new Error("La solicitud tardó demasiado tiempo. Verifica tu conexión.");
    }
    
    if (!error.response) {
      throw new Error("Error de conexión. Verifica que el servidor esté disponible.");
    }
    
    const status = error.response.status;
    const message = error.response.data?.message || error.message;
    
    switch (status) {
      case 400:
        throw new Error(`Solicitud inválida: ${message}`);
      case 401:
        throw new Error("No autorizado");
      case 403:
        throw new Error("Acceso denegado");
      case 404:
        throw new Error("Recurso no encontrado");
      case 500:
        throw new Error("Error interno del servidor");
      default:
        throw new Error(message || "Error desconocido");
    }
  }
);

// API functions
export const notesApi = {
  // Obtener todas las notas
  getAllNotes: async (): Promise<Note[]> => {
    try {
      const response = await api.get<ApiResponse<Note[]>>("/notes");
      return response.data.data || [];
    } catch (error) {
      console.error("Error fetching notes:", error);
      throw error;
    }
  },

  // Obtener nota por ID
  getNoteById: async (id: number): Promise<Note> => {
    const response = await api.get<ApiResponse<Note>>(`/notes/${id}`);
    if (response.data.status === "error") {
      throw new Error(response.data.message);
    }
    return response.data.data;
  },

  // Crear nueva nota
  createNote: async (note: Omit<Note, "id" | "createdAt" | "updatedAt">): Promise<Note> => {
    const response = await api.post<ApiResponse<Note>>("/notes", note);
    if (response.data.status === "error") {
      throw new Error(response.data.message);
    }
    return response.data.data;
  },

  // Actualizar nota
  updateNote: async (id: number, note: Partial<Note>): Promise<Note> => {
    const response = await api.put<ApiResponse<Note>>(`/notes/${id}`, note);
    if (response.data.status === "error") {
      throw new Error(response.data.message);
    }
    return response.data.data;
  },

  // Eliminar nota
  deleteNote: async (id: number): Promise<void> => {
    const response = await api.delete<ApiResponse<void>>(`/notes/${id}`);
    if (response.data.status === "error") {
      throw new Error(response.data.message);
    }
  },

  // Buscar notas por palabra clave
  searchNotes: async (keyword: string): Promise<Note[]> => {
    const response = await api.get<ApiResponse<Note[]>>(`/notes/search`, {
      params: { keyword: keyword.trim() }
    });
    return response.data.data || [];
  },

  // Filtrar notas con múltiples criterios
  filterNotes: async (filters: FilterOptions): Promise<Note[]> => {
    const cleanFilters = Object.fromEntries(
      Object.entries(filters).filter(([_, value]) => value !== undefined && value !== null && value !== "")
    );
    
    const response = await api.get<ApiResponse<Note[]>>("/notes/filter", {
      params: cleanFilters
    });
    return response.data.data || [];
  },

  // Obtener todas las categorías
  getCategories: async (): Promise<string[]> => {
    try {
      const response = await api.get<ApiResponse<string[]>>("/notes/categories");
      return response.data.data || [];
    } catch (error) {
      console.error("Error fetching categories:", error);
      return [];
    }
  },

  // Obtener estadísticas
  getStats: async (): Promise<NoteStats> => {
    const response = await api.get<ApiResponse<NoteStats>>("/notes/stats");
    if (response.data.status === "error") {
      throw new Error(response.data.message);
    }
    return response.data.data || { total: 0, high: 0, medium: 0, low: 0 };
  },

  // Obtener notas recientes
  getRecentNotes: async (limit: number = 10): Promise<Note[]> => {
    const response = await api.get<ApiResponse<Note[]>>("/notes/recent", {
      params: { limit }
    });
    return response.data.data || [];
  },

  // Health check
  healthCheck: async (): Promise<boolean> => {
    try {
      const response = await api.get("/notes/health");
      return response.status === 200;
    } catch (error) {
      return false;
    }
  },
};'

create_file "src/lib/utils.ts" 'import { Note } from "@/types";
import clsx, { ClassValue } from "clsx";

export function cn(...inputs: ClassValue[]) {
  return clsx(inputs);
}

export const getPriorityColor = (priority: Note["priority"]) => {
  switch (priority) {
    case "HIGH":
      return {
        bg: "bg-red-500",
        text: "text-red-700",
        border: "border-red-500",
        light: "bg-red-50",
        gradient: "from-red-500 to-red-600",
      };
    case "MEDIUM":
      return {
        bg: "bg-yellow-500",
        text: "text-yellow-700",
        border: "border-yellow-500",
        light: "bg-yellow-50",
        gradient: "from-yellow-500 to-yellow-600",
      };
    case "LOW":
      return {
        bg: "bg-green-500",
        text: "text-green-700",
        border: "border-green-500",
        light: "bg-green-50",
        gradient: "from-green-500 to-green-600",
      };
    default:
      return {
        bg: "bg-gray-500",
        text: "text-gray-700",
        border: "border-gray-500",
        light: "bg-gray-50",
        gradient: "from-gray-500 to-gray-600",
      };
  }
};

export const getPriorityLabel = (priority: Note["priority"]) => {
  switch (priority) {
    case "HIGH": return "🔴 Alta";
    case "MEDIUM": return "🟡 Media";
    case "LOW": return "🟢 Baja";
    default: return "⚪ Sin definir";
  }
};

export const formatDate = (dateString: string): string => {
  try {
    const date = new Date(dateString);
    const now = new Date();
    const diffInMs = now.getTime() - date.getTime();
    const diffInHours = diffInMs / (1000 * 60 * 60);
    const diffInDays = diffInMs / (1000 * 60 * 60 * 24);

    // Si es hoy
    if (diffInDays < 1 && date.getDate() === now.getDate()) {
      if (diffInHours < 1) {
        const diffInMinutes = Math.floor(diffInMs / (1000 * 60));
        return diffInMinutes < 1 ? "Ahora mismo" : `Hace ${diffInMinutes} min`;
      }
      return `Hace ${Math.floor(diffInHours)} h`;
    }

    // Si es ayer
    if (diffInDays < 2 && diffInDays >= 1) {
      return `Ayer ${date.toLocaleTimeString("es-ES", { 
        hour: "2-digit", 
        minute: "2-digit" 
      })}`;
    }

    // Si es esta semana
    if (diffInDays < 7) {
      return date.toLocaleDateString("es-ES", { 
        weekday: "long",
        hour: "2-digit",
        minute: "2-digit"
      });
    }

    // Fecha completa
    return new Intl.DateTimeFormat("es-ES", {
      year: "numeric",
      month: "short",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    }).format(date);
  } catch (error) {
    console.error("Error formatting date:", error);
    return "Fecha inválida";
  }
};

export const truncateText = (text: string, maxLength: number = 150): string => {
  if (!text || text.length <= maxLength) return text;
  return text.substring(0, maxLength).trim() + "...";
};

export const getCategoryIcon = (category: string): string => {
  const categoryLower = category.toLowerCase();
  
  const iconMap: Record<string, string> = {
    trabajo: "💼",
    personal: "👤",
    estudio: "📚",
    estudios: "📚",
    idea: "💡",
    ideas: "💡",
    compra: "🛒",
    compras: "🛒",
    salud: "🏥",
    familia: "👨‍👩‍👧‍👦",
    casa: "🏠",
    hogar: "🏠",
    viaje: "✈️",
    viajes: "✈️",
    deporte: "⚽",
    deportes: "⚽",
    cocina: "👨‍🍳",
    música: "🎵",
    musica: "🎵",
    libro: "📖",
    libros: "📖",
    película: "🎬",
    peliculas: "🎬",
    cine: "🎬",
    finanzas: "💰",
    dinero: "💰",
  };

  for (const [key, icon] of Object.entries(iconMap)) {
    if (categoryLower.includes(key)) {
      return icon;
    }
  }

  return "📁";
};'

echo -e "${BLUE}🎣 Generando hooks personalizados...${NC}"

# =====================================================
# HOOKS
# =====================================================

create_file "src/hooks/useDebounce.ts" 'import { useEffect, useState } from "react"

export function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value)

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value)
    }, delay)

    return () => {
      clearTimeout(handler)
    }
  }, [value, delay])

  return debouncedValue
}'

create_file "src/hooks/useLocalStorage.ts" 'import { useState, useEffect } from "react"

export function useLocalStorage<T>(
  key: string,
  initialValue: T
): [T, (value: T | ((val: T) => T)) => void] {
  const [storedValue, setStoredValue] = useState<T>(initialValue)

  useEffect(() => {
    try {
      const item = window.localStorage.getItem(key)
      if (item) {
        setStoredValue(JSON.parse(item))
      }
    } catch (error) {
      console.error(`Error reading localStorage key "${key}":`, error)
    }
  }, [key])

  const setValue = (value: T | ((val: T) => T)) => {
    try {
      const valueToStore = value instanceof Function ? value(storedValue) : value
      setStoredValue(valueToStore)
      window.localStorage.setItem(key, JSON.stringify(valueToStore))
    } catch (error) {
      console.error(`Error setting localStorage key "${key}":`, error)
    }
  }

  return [storedValue, setValue]
}'

create_file "src/hooks/useKeyboard.ts" 'import { useEffect } from "react"

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
}'

echo -e "${BLUE}🏪 Generando store Zustand...${NC}"

# =====================================================
# STORE
# =====================================================

create_file "src/store/notes-store.tsx" '"use client"

import { create } from "zustand"
import { subscribeWithSelector } from "zustand/middleware"
import { immer } from "zustand/middleware/immer"
import { createContext, useContext, ReactNode } from "react"
import { Note, NoteStats, NoteFormData } from "@/types"
import { notesApi } from "@/lib/api"
import toast from "react-hot-toast"

interface NotesState {
  // Data
  notes: Note[]
  filteredNotes: Note[]
  categories: string[]
  stats: NoteStats
  
  // UI State
  isLoading: boolean
  isFormLoading: boolean
  showForm: boolean
  editingNote: Note | null
  
  // Filters
  searchKeyword: string
  selectedCategory: string
  selectedPriority: string
  
  // Actions
  setNotes: (notes: Note[]) => void
  setFilteredNotes: (notes: Note[]) => void
  setCategories: (categories: string[]) => void
  setStats: (stats: NoteStats) => void
  setLoading: (loading: boolean) => void
  setFormLoading: (loading: boolean) => void
  setShowForm: (show: boolean) => void
  setEditingNote: (note: Note | null) => void
  setSearchKeyword: (keyword: string) => void
  setSelectedCategory: (category: string) => void
  setSelectedPriority: (priority: string) => void
  
  // Async Actions
  loadInitialData: () => Promise<void>
  createNote: (formData: NoteFormData) => Promise<void>
  updateNote: (id: number, formData: NoteFormData) => Promise<void>
  deleteNote: (id: number) => Promise<void>
  searchNotes: (keyword: string) => Promise<void>
  filterNotes: () => Promise<void>
  refreshData: () => Promise<void>
}

const useNotesStore = create<NotesState>()(
  subscribeWithSelector(
    immer((set, get) => ({
      // Initial state
      notes: [],
      filteredNotes: [],
      categories: [],
      stats: { total: 0, high: 0, medium: 0, low: 0 },
      isLoading: true,
      isFormLoading: false,
      showForm: false,
      editingNote: null,
      searchKeyword: "",
      selectedCategory: "",
      selectedPriority: "",

      // Setters
      setNotes: (notes) => set((state) => { state.notes = notes }),
      setFilteredNotes: (notes) => set((state) => { state.filteredNotes = notes }),
      setCategories: (categories) => set((state) => { state.categories = categories }),
      setStats: (stats) => set((state) => { state.stats = stats }),
      setLoading: (loading) => set((state) => { state.isLoading = loading }),
      setFormLoading: (loading) => set((state) => { state.isFormLoading = loading }),
      setShowForm: (show) => set((state) => { state.showForm = show }),
      setEditingNote: (note) => set((state) => { state.editingNote = note }),
      setSearchKeyword: (keyword) => set((state) => { state.searchKeyword = keyword }),
      setSelectedCategory: (category) => set((state) => { state.selectedCategory = category }),
      setSelectedPriority: (priority) => set((state) => { state.selectedPriority = priority }),

      // Async actions
      loadInitialData: async () => {
        try {
          set((state) => { state.isLoading = true })
          
          const [notesData, categoriesData, statsData] = await Promise.all([
            notesApi.getAllNotes(),
            notesApi.getCategories(),
            notesApi.getStats(),
          ])

          set((state) => {
            state.notes = notesData
            state.filteredNotes = notesData
            state.categories = categoriesData
            state.stats = statsData
          })
        } catch (error) {
          console.error("Error loading initial data:", error)
          toast.error("Error al cargar los datos iniciales")
        } finally {
          set((state) => { state.isLoading = false })
        }
      },

      createNote: async (formData) => {
        try {
          set((state) => { state.isFormLoading = true })
          
          await notesApi.createNote(formData)
          
          set((state) => {
            state.showForm = false
            state.editingNote = null
          })
          
          toast.success("Nota creada correctamente")
          await get().loadInitialData()
        } catch (error) {
          console.error("Error creating note:", error)
          toast.error("Error al crear la nota")
        } finally {
          set((state) => { state.isFormLoading = false })
        }
      },

      updateNote: async (id, formData) => {
        try {
          set((state) => { state.isFormLoading = true })
          
          await notesApi.updateNote(id, formData)
          
          set((state) => {
            state.showForm = false
            state.editingNote = null
          })
          
          toast.success("Nota actualizada correctamente")
          await get().loadInitialData()
        } catch (error) {
          console.error("Error updating note:", error)
          toast.error("Error al actualizar la nota")
        } finally {
          set((state) => { state.isFormLoading = false })
        }
      },

      deleteNote: async (id) => {
        try {
          await notesApi.deleteNote(id)
          toast.success("Nota eliminada correctamente")
          await get().loadInitialData()
        } catch (error) {
          console.error("Error deleting note:", error)
          toast.error("Error al eliminar la nota")
        }
      },

      searchNotes: async (keyword) => {
        try {
          if (!keyword.trim()) {
            set((state) => { state.filteredNotes = state.notes })
            return
          }
          
          const filtered = await notesApi.searchNotes(keyword)
          set((state) => { state.filteredNotes = filtered })
        } catch (error) {
          console.error("Error searching notes:", error)
          toast.error("Error en la búsqueda")
        }
      },

      filterNotes: async () => {
        try {
          const { searchKeyword, selectedCategory, selectedPriority, notes } = get()
          
          if (!searchKeyword && !selectedCategory && !selectedPriority) {
            set((state) => { state.filteredNotes = state.notes })
            return
          }

          const filtered = await notesApi.filterNotes({
            keyword: searchKeyword || undefined,
            category: selectedCategory || undefined,
            priority: selectedPriority as Note["priority"] || undefined,
          })

          set((state) => { state.filteredNotes = filtered })
        } catch (error) {
          console.error("Error filtering notes:", error)
          toast.error("Error al aplicar filtros")
        }
      },

      refreshData: async () => {
        await get().loadInitialData()
        toast.success("Datos actualizados correctamente")
      },
    }))
  )
)

const NotesContext = createContext<ReturnType<typeof useNotesStore> | null>(null)

export function NotesProvider({ children }: { children: ReactNode }) {
  return (
    <NotesContext.Provider value={useNotesStore}>
      {children}
    </NotesContext.Provider>
  )
}

export const useNotes = () => {
  const context = useContext(NotesContext)
  if (!context) {
    throw new Error("useNotes must be used within NotesProvider")
  }
  return context()
}'

echo -e "${GREEN}✨ ¡Frontend Next.js 15 generado exitosamente!${NC}"
echo ""
echo -e "${YELLOW}📋 Próximos pasos:${NC}"
echo "1. cd $PROJECT_DIR"
echo "2. npm install"
echo "3. npm run dev"
echo ""
echo -e "${BLUE}🌐 URLs de desarrollo:${NC}"
echo "• Frontend: http://localhost:3000"
echo "• API: Configurar NEXT_PUBLIC_API_URL en .env.local"
echo ""
echo -e "${GREEN}🚀 ¡Tu aplicación Next.js 15 está lista para usar!${NC}"