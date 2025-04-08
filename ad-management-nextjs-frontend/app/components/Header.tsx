'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { FaGooglePlay, FaCar, FaUserTie, FaBars, FaTimes } from 'react-icons/fa';

const Header = () => {
  const [isScrolled, setIsScrolled] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [activeSection, setActiveSection] = useState('home');

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 10);

      // Update active section based on scroll position
      const sections = ['home', 'how-it-works', 'features', 'benefits', 'pricing', 'contact'];
      let currentSection = 'home';

      for (const section of sections) {
        const element = document.getElementById(section);
        if (element) {
          const rect = element.getBoundingClientRect();
          if (rect.top <= 200 && rect.bottom >= 200) {
            currentSection = section;
            break;
          }
        }
      }
      
      setActiveSection(currentSection);
    };
    
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const navItems = [
    { label: 'Home', href: '#home', icon: null },
    { label: 'How It Works', href: '#how-it-works', icon: null },
    { label: 'Features', href: '#features', icon: null },
    { label: 'Benefits', href: '#benefits', icon: null },
    { label: 'Pricing', href: '#pricing', icon: null },
    { label: 'Contact', href: '#contact', icon: null },
  ];

  const ctaButtons = [
    { label: 'For Drivers', href: '#driver-signup', icon: FaCar },
    { label: 'For Companies', href: '#company-signup', icon: FaUserTie },
  ];

  return (
    <motion.header 
      className={`fixed top-0 left-0 right-0 z-50 backdrop-blur-lg transition-all duration-300 ${
        isScrolled ? 'bg-white/95 shadow-lg' : 'bg-transparent'
      }`}
      initial={{ y: -100 }}
      animate={{ y: 0 }}
      transition={{ duration: 0.5, ease: "easeOut" }}
    >
      <div className="container">
        <nav className="flex items-center justify-between py-4">
          <motion.a 
            href="#" 
            className="text-2xl font-bold text-[#1E1E1E] flex items-center"
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            <motion.div
              initial={{ rotate: 0 }}
              animate={{ rotate: [0, 5, 0, -5, 0] }}
              transition={{ duration: 5, repeat: Infinity, ease: "easeInOut" }}
              className="mr-2"
            >
              🚕
            </motion.div>
            DisplayOnWheels
          </motion.a>
          
          {/* Desktop Navigation */}
          <div className="hidden md:flex items-center space-x-2">
            <nav className="flex mr-4">
              {navItems.map((item) => (
                <motion.a
                  key={item.label}
                  href={item.href}
                  className={`relative px-3 py-2 text-[#1E1E1E] hover:text-[#F8A717] transition-colors ${
                    activeSection === item.href.substring(1) ? 'text-[#F8A717]' : ''
                  }`}
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                >
                  {item.label}
                  {activeSection === item.href.substring(1) && (
                    <motion.div
                      layoutId="activeIndicator"
                      className="absolute bottom-0 left-0 right-0 h-0.5 bg-[#F8A717]"
                      transition={{ duration: 0.3 }}
                    />
                  )}
                </motion.a>
              ))}
            </nav>
            
            <div className="flex space-x-2">
              {ctaButtons.map((button) => (
                <motion.a
                  key={button.label}
                  href={button.href}
                  className="bg-[#F8A717] hover:bg-[#F8A717]/90 text-white px-4 py-2 rounded-lg font-medium transition-all duration-300 shadow-md flex items-center"
                  whileHover={{ 
                    scale: 1.05, 
                    boxShadow: "0 10px 15px -3px rgba(248, 167, 23, 0.3)" 
                  }}
                  whileTap={{ scale: 0.95 }}
                >
                  {button.icon && <button.icon className="mr-2" />}
                  {button.label}
                </motion.a>
              ))}
              
              <motion.a
                href="#download"
                className="bg-[#1E1E1E] hover:bg-[#1E1E1E]/90 text-white px-4 py-2 rounded-lg font-medium transition-all duration-300 shadow-md flex items-center"
                whileHover={{ 
                  scale: 1.05, 
                  boxShadow: "0 10px 15px -3px rgba(30, 30, 30, 0.3)" 
                }}
                whileTap={{ scale: 0.95 }}
              >
                <FaGooglePlay className="mr-2" />
                Download
              </motion.a>
            </div>
          </div>

          {/* Mobile Menu Button */}
          <motion.button
            className="md:hidden text-[#1E1E1E] focus:outline-none"
            onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
            whileHover={{ scale: 1.1 }}
            whileTap={{ scale: 0.9 }}
          >
            {isMobileMenuOpen ? (
              <FaTimes className="w-6 h-6" />
            ) : (
              <FaBars className="w-6 h-6" />
            )}
          </motion.button>
        </nav>
      </div>

      {/* Mobile Menu */}
      <AnimatePresence>
        {isMobileMenuOpen && (
          <motion.div
            className="md:hidden bg-white shadow-lg"
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            exit={{ opacity: 0, height: 0 }}
            transition={{ duration: 0.3 }}
          >
            <div className="container mx-auto py-4">
              <div className="flex flex-col space-y-2">
                {navItems.map((item) => (
                  <motion.a
                    key={item.label}
                    href={item.href}
                    className={`px-4 py-3 rounded-lg hover:bg-[#F8A717]/10 ${
                      activeSection === item.href.substring(1) 
                        ? 'text-[#F8A717] bg-[#F8A717]/10' 
                        : 'text-[#1E1E1E]'
                    }`}
                    onClick={() => setIsMobileMenuOpen(false)}
                    whileHover={{ x: 5 }}
                    whileTap={{ scale: 0.98 }}
                  >
                    {item.label}
                  </motion.a>
                ))}
                
                <div className="pt-4 grid grid-cols-1 gap-3">
                  {ctaButtons.map((button) => (
                    <motion.a
                      key={button.label}
                      href={button.href}
                      className="bg-[#F8A717] hover:bg-[#F8A717]/90 text-white px-4 py-3 rounded-lg font-medium shadow-md flex items-center justify-center"
                      onClick={() => setIsMobileMenuOpen(false)}
                      whileHover={{ scale: 1.02 }}
                      whileTap={{ scale: 0.98 }}
                    >
                      {button.icon && <button.icon className="mr-2" />}
                      {button.label}
                    </motion.a>
                  ))}
                  
                  <motion.a
                    href="#download"
                    className="bg-[#1E1E1E] hover:bg-[#1E1E1E]/90 text-white px-4 py-3 rounded-lg font-medium shadow-md flex items-center justify-center"
                    onClick={() => setIsMobileMenuOpen(false)}
                    whileHover={{ scale: 1.02 }}
                    whileTap={{ scale: 0.98 }}
                  >
                    <FaGooglePlay className="mr-2" />
                    Download App
                  </motion.a>
                </div>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.header>
  );
};

export default Header; 