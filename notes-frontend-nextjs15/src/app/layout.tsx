import { Inter, Fira_Code } from "next/font/google"
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
}
