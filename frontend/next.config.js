/** @type {import("next").NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  output: "standalone",
  
  // Configuración experimental para Next.js 15
  experimental: {
    optimizePackageImports: ["lucide-react", "@headlessui/react"],
  },

  turbopack: {
    rules: {
      "*.svg": {
        loaders: ["@svgr/webpack"],
        as: "*.js",
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
    contentSecurityPolicy: "default-src 'self'; script-src 'none'; sandbox;",
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

module.exports = nextConfig
