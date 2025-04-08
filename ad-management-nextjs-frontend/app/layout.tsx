import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'], variable: '--font-inter' })

export const metadata: Metadata = {
  title: 'DisplayOnWheels - Revolutionary Car Advertising Platform',
  description: 'Transform your vehicle into a revenue stream with DisplayOnWheels. Our innovative platform connects drivers and businesses for mobile advertising opportunities.',
  keywords: 'car advertising, mobile advertising, driver earnings, vehicle ads, display on wheels',
  openGraph: {
    title: 'DisplayOnWheels - Revolutionary Car Advertising Platform',
    description: 'Transform your vehicle into a revenue stream with DisplayOnWheels',
    url: 'https://displayonwheels.com',
    siteName: 'DisplayOnWheels',
    images: [
      {
        url: 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8', 
        width: 1200,
        height: 630,
        alt: 'DisplayOnWheels',
      },
    ],
    locale: 'en_US',
    type: 'website',
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className={inter.variable}>
      <body className="antialiased">
        {children}
      </body>
    </html>
  )
} 