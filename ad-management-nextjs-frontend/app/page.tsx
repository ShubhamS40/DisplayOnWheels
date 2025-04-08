'use client';

import Hero from './components/Hero';
import HowItWorks from './components/HowItWorks';
import KeyFeatures from './components/KeyFeatures';
import Benefits from './components/Benefits';
import Testimonials from './components/Testimonials';
import Pricing from './components/Pricing';
import Features from './components/Features';
import CallToAction from './components/CallToAction';
import Footer from './components/Footer';
import Header from './components/Header';
import StatsShowcase from './components/StatsShowcase';
import Contact from './components/Contact';

export default function Home() {
  return (
    <main className="min-h-screen">
      <Header />
      <Hero />
      <StatsShowcase />
      <HowItWorks />
      <KeyFeatures />
      <Features />
      <Benefits />
      <Testimonials />
      <Pricing />
      <CallToAction />
      <Contact />
      <Footer />
    </main>
  );
} 