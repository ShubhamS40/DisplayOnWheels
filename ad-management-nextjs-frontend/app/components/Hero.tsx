'use client';

import { motion, AnimatePresence } from 'framer-motion';
import Image from 'next/image';
import { useState, useEffect } from 'react';
import { FaGooglePlay, FaArrowRight } from 'react-icons/fa';

const adMessages = [
  "Turn your commute into cash",
  "Advertise on the go",
  "Earn while you drive", 
  "Make your car work for you"
];

const Hero = () => {
  const [currentAd, setCurrentAd] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentAd((prev) => (prev + 1) % adMessages.length);
    }, 3000);
    return () => clearInterval(interval);
  }, []);

  return (
    <section className="relative min-h-screen flex items-center bg-white overflow-hidden">
      {/* Parallax Background Effect */}
      <motion.div 
        className="absolute inset-0 z-0"
        initial={{ y: 0 }}
        animate={{ 
          y: [0, -15, 0],
        }}
        transition={{ 
          repeat: Infinity,
          duration: 20,
          ease: "linear"
        }}
      >
        <Image
          src="https://images.unsplash.com/photo-1494976388531-d1058494cdd8"
          alt="Hero background - Sports Car"
          fill
          className="object-cover opacity-20"
          priority
        />
        {/* Dynamic Patterns */}
        <div className="absolute inset-0">
          <svg className="absolute right-0 top-0 h-full w-1/3 text-[#F8A717]/10" fill="currentColor">
            <pattern id="heroPattern" width="40" height="40" patternUnits="userSpaceOnUse">
              <path d="M0 40L40 0H20L0 20M40 40V20L20 40" />
            </pattern>
            <rect width="100%" height="100%" fill="url(#heroPattern)" />
          </svg>
        </div>
        {/* Enhanced Gradient Overlay */}
        <div className="absolute inset-0 bg-gradient-to-r from-[#F8A717]/20 via-transparent to-[#1E1E1E]/20 mix-blend-overlay" />
      </motion.div>

      <div className="container relative z-10">
        <div className="grid md:grid-cols-2 gap-12 items-center">
          <motion.div
            initial={{ opacity: 0, x: -50 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.7, ease: "easeOut" }}
            className="relative"
          >
            <motion.span 
              className="inline-block px-4 py-1 mb-4 bg-[#F8A717] text-white rounded-full text-sm font-medium"
              initial={{ opacity: 0, y: -20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.2, duration: 0.5 }}
            >
              Revolutionary Mobile Advertising
            </motion.span>
            
            <h1 className="text-4xl md:text-6xl font-bold text-[#1E1E1E] mb-6">
              Transform Your <span className="text-[#F8A717]">Vehicle</span> Into A Revenue Stream
            </h1>
            
            <div className="h-12 mb-6 overflow-hidden">
              <AnimatePresence mode="wait">
                <motion.p 
                  key={currentAd}
                  initial={{ y: 40, opacity: 0 }}
                  animate={{ y: 0, opacity: 1 }}
                  exit={{ y: -40, opacity: 0 }}
                  transition={{ duration: 0.5 }}
                  className="text-xl text-[#1E1E1E]"
                >
                  {adMessages[currentAd]}
                </motion.p>
              </AnimatePresence>
            </div>
            
            <p className="text-lg text-[#1E1E1E]/80 mb-8">
              Join the future of mobile advertising with DisplayOnWheels. Turn your daily commute into profitable advertising space.
            </p>
            
            <div className="flex flex-col sm:flex-row gap-4">
              <motion.button
                whileHover={{ scale: 1.05, boxShadow: "0 10px 25px -5px rgba(248, 167, 23, 0.4)" }}
                whileTap={{ scale: 0.95 }}
                className="bg-[#F8A717] hover:bg-[#F8A717]/90 text-white px-8 py-3 rounded-lg text-lg font-semibold transition-all duration-300 shadow-lg flex items-center justify-center"
              >
                Get Started
                <FaArrowRight className="ml-2" />
              </motion.button>
              
              <motion.button
                whileHover={{ scale: 1.05, boxShadow: "0 10px 25px -5px rgba(30, 30, 30, 0.3)" }}
                whileTap={{ scale: 0.95 }}
                className="bg-[#1E1E1E] hover:bg-[#1E1E1E]/90 text-white px-8 py-3 rounded-lg text-lg font-semibold transition-all duration-300 shadow-lg flex items-center justify-center"
              >
                <FaGooglePlay className="mr-2" />
                Google Play
              </motion.button>
            </div>
            
            {/* Enhanced Decorative Elements */}
            <motion.div 
              className="absolute -left-8 -bottom-8 w-24 h-24 bg-[#FF914D]/30 rounded-full blur-xl"
              animate={{ 
                scale: [1, 1.2, 1],
                opacity: [0.5, 0.7, 0.5]
              }}
              transition={{ 
                duration: 4,
                repeat: Infinity,
                ease: "easeInOut"
              }}
            />
            <motion.div 
              className="absolute -right-4 top-4 w-16 h-16 bg-[#F8A717]/20 rounded-full blur-lg"
              animate={{ 
                scale: [1, 1.3, 1],
                opacity: [0.3, 0.6, 0.3]
              }}
              transition={{ 
                duration: 5,
                repeat: Infinity,
                ease: "easeInOut",
                delay: 1
              }}
            />
          </motion.div>

          <motion.div
            initial={{ opacity: 0, x: 50 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.7, delay: 0.2, ease: "easeOut" }}
            className="relative"
          >
            <div className="relative h-[500px] flex items-center justify-center">
              {/* Ad Panel Animation */}
              <div className="relative w-[320px] h-[220px] bg-[#1E1E1E] rounded-lg shadow-2xl overflow-hidden">
                <motion.div
                  animate={{ 
                    y: ["0%", "-100%", "-200%", "-300%", "0%"],
                  }}
                  transition={{ 
                    duration: 10,
                    repeat: Infinity,
                    ease: "easeInOut"
                  }}
                  className="absolute w-full"
                >
                  {/* Ad Panel 1 */}
                  <div className="w-[320px] h-[220px] bg-[#F8A717] p-6 flex flex-col justify-center items-center">
                    <h3 className="text-white text-xl font-bold mb-2">Coffee Shop Promo</h3>
                    <p className="text-white/90 text-center">Get 20% off your next coffee with code WHEELS</p>
                  </div>
                  
                  {/* Ad Panel 2 */}
                  <div className="w-[320px] h-[220px] bg-[#FF914D] p-6 flex flex-col justify-center items-center">
                    <h3 className="text-white text-xl font-bold mb-2">Summer Sale</h3>
                    <p className="text-white/90 text-center">Shop our collection with 30% discount</p>
                  </div>
                  
                  {/* Ad Panel 3 */}
                  <div className="w-[320px] h-[220px] bg-[#1E1E1E] p-6 flex flex-col justify-center items-center">
                    <h3 className="text-white text-xl font-bold mb-2">Tech Expo 2023</h3>
                    <p className="text-white/90 text-center">Visit us at booth 42 for exclusive demos</p>
                  </div>
                  
                  {/* Ad Panel 4 */}
                  <div className="w-[320px] h-[220px] bg-[#F8A717] p-6 flex flex-col justify-center items-center">
                    <h3 className="text-white text-xl font-bold mb-2">Coffee Shop Promo</h3>
                    <p className="text-white/90 text-center">Get 20% off your next coffee with code WHEELS</p>
                  </div>
                </motion.div>
                
               
              </div>
              
              {/* Floating elements */}
              <motion.div
                className="absolute w-16 h-16 bg-[#FF914D]/20 rounded-full top-[20%] right-[10%]"
                animate={{ 
                  y: [0, -15, 0],
                  opacity: [0.7, 1, 0.7]
                }}
                transition={{ 
                  duration: 3,
                  repeat: Infinity,
                  ease: "easeInOut"
                }}
              />
              <motion.div
                className="absolute w-12 h-12 bg-[#F8A717]/30 rounded-full bottom-[30%] left-[15%]"
                animate={{ 
                  y: [0, 15, 0],
                  opacity: [0.5, 0.8, 0.5]
                }}
                transition={{ 
                  duration: 4,
                  repeat: Infinity,
                  ease: "easeInOut",
                  delay: 1
                }}
              />
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
};

export default Hero; 