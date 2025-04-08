'use client';

import { motion } from 'framer-motion';

const MobileAppShowcase = () => {
  return (
    <section className="section bg-[#F5F5F5] py-20">
      <div className="container mx-auto px-4">
        <motion.div
          className="text-center mb-16"
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.7 }}
        >
          <span className="inline-block px-4 py-1 mb-4 bg-[#F8A717]/10 text-[#F8A717] rounded-full text-sm font-medium">
            Mobile Experience
          </span>
          <h2 className="text-3xl md:text-4xl font-bold mb-4 text-[#1E1E1E]">
            Manage Everything from Your Smartphone
          </h2>
          <p className="text-[#1E1E1E]/70 max-w-2xl mx-auto text-lg">
            Our powerful mobile app puts you in control of your advertising experience on the go.
          </p>
          
          {/* Mobile mockup created with CSS */}
          <div className="mt-16 flex justify-center">
            <div className="relative">
              {/* Phone frame */}
              <div className="relative w-[280px] h-[580px] bg-[#252525] rounded-[40px] p-3 shadow-xl mx-auto">
                {/* Phone screen */}
                <div className="w-full h-full bg-[#F8F8F8] rounded-[32px] overflow-hidden relative">
                  {/* Status bar */}
                  <div className="h-8 w-full bg-[#F8A717] flex items-center justify-between px-5">
                    <div className="text-white text-xs">9:41</div>
                    <div className="flex items-center space-x-1">
                      <div className="w-3 h-3 rounded-full bg-white"></div>
                      <div className="w-3 h-3 rounded-full bg-white"></div>
                      <div className="w-3 h-3 rounded-full bg-white"></div>
                    </div>
                  </div>
                  
                  {/* App content */}
                  <div className="p-4">
                    <div className="h-10 bg-white rounded-lg shadow-sm mb-4 flex items-center px-3">
                      <div className="w-4 h-4 bg-[#F8A717] rounded-full mr-2"></div>
                      <div className="text-sm font-medium text-gray-800">Search ads...</div>
                    </div>
                    
                    <div className="grid grid-cols-2 gap-3 mb-4">
                      <div className="bg-white p-3 rounded-lg shadow-sm">
                        <div className="w-6 h-6 bg-[#F8A717] rounded-md mb-2"></div>
                        <div className="h-2 bg-gray-300 rounded-full w-14 mb-1"></div>
                        <div className="h-2 bg-gray-200 rounded-full w-10"></div>
                      </div>
                      <div className="bg-white p-3 rounded-lg shadow-sm">
                        <div className="w-6 h-6 bg-[#3B82F6] rounded-md mb-2"></div>
                        <div className="h-2 bg-gray-300 rounded-full w-14 mb-1"></div>
                        <div className="h-2 bg-gray-200 rounded-full w-10"></div>
                      </div>
                    </div>
                    
                    <div className="mb-4">
                      <div className="h-3 bg-gray-300 rounded-full w-24 mb-2"></div>
                      <div className="bg-white rounded-lg shadow-sm p-3">
                        <div className="flex items-center justify-between mb-2">
                          <div className="h-2 bg-gray-300 rounded-full w-20"></div>
                          <div className="h-6 w-10 bg-[#F8A717] rounded-md"></div>
                        </div>
                        <div className="h-24 bg-gray-100 rounded-md mb-2 flex items-center justify-center">
                          <div className="text-xs text-gray-400">Ad Preview</div>
                        </div>
                        <div className="flex justify-between">
                          <div className="h-2 bg-gray-300 rounded-full w-16"></div>
                          <div className="h-2 bg-gray-300 rounded-full w-12"></div>
                        </div>
                      </div>
                    </div>
                    
                    <div className="grid grid-cols-3 gap-2">
                      <div className="h-16 bg-white rounded-lg shadow-sm flex items-center justify-center">
                        <div className="w-8 h-8 bg-[#F8A717]/20 rounded-full flex items-center justify-center">
                          <div className="w-4 h-4 bg-[#F8A717] rounded-sm"></div>
                        </div>
                      </div>
                      <div className="h-16 bg-white rounded-lg shadow-sm flex items-center justify-center">
                        <div className="w-8 h-8 bg-[#3B82F6]/20 rounded-full flex items-center justify-center">
                          <div className="w-4 h-4 bg-[#3B82F6] rounded-sm"></div>
                        </div>
                      </div>
                      <div className="h-16 bg-white rounded-lg shadow-sm flex items-center justify-center">
                        <div className="w-8 h-8 bg-[#10B981]/20 rounded-full flex items-center justify-center">
                          <div className="w-4 h-4 bg-[#10B981] rounded-sm"></div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                
                {/* Phone notch */}
                <div className="absolute top-0 left-1/2 transform -translate-x-1/2 w-1/3 h-6 bg-[#252525] rounded-b-xl z-10"></div>
                
                {/* Phone home button */}
                <div className="absolute bottom-1 left-1/2 transform -translate-x-1/2 w-1/3 h-1 bg-gray-400 rounded-full"></div>
              </div>
              
              {/* Floating elements */}
              <motion.div 
                className="absolute top-[20%] right-[-15%] bg-white p-3 rounded-lg shadow-lg"
                initial={{ opacity: 0, x: 20 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true }}
                transition={{ delay: 0.3, duration: 0.5 }}
              >
                <div className="w-10 h-10 bg-[#F8A717]/80 rounded-md flex items-center justify-center">
                  <div className="w-5 h-5 border-2 border-white rounded-full"></div>
                </div>
              </motion.div>
              
              <motion.div 
                className="absolute bottom-[25%] left-[-15%] bg-white p-3 rounded-lg shadow-lg"
                initial={{ opacity: 0, x: -20 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true }}
                transition={{ delay: 0.6, duration: 0.5 }}
              >
                <div className="w-10 h-10 bg-[#3B82F6]/80 rounded-md flex items-center justify-center">
                  <div className="w-5 h-5">
                    <div className="w-full h-1 bg-white mb-1 rounded-full"></div>
                    <div className="w-3/4 h-1 bg-white mb-1 rounded-full"></div>
                    <div className="w-1/2 h-1 bg-white rounded-full"></div>
                  </div>
                </div>
              </motion.div>
            </div>
          </div>
          
          <div className="mt-12 flex justify-center gap-4">
            <motion.button
              className="bg-[#1E1E1E] text-white px-6 py-3 rounded-lg shadow-lg flex items-center gap-2"
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
            >
              <div className="w-5 h-5 rounded-md flex items-center justify-center">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className="w-4 h-4">
                  <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8z" />
                </svg>
              </div>
              App Store
            </motion.button>
            <motion.button
              className="bg-[#F8A717] text-white px-6 py-3 rounded-lg shadow-lg flex items-center gap-2"
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
            >
              <div className="w-5 h-5 rounded-md flex items-center justify-center">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className="w-4 h-4">
                  <path d="M12 2L4.5 20.29l.71.71L12 18l6.79 3 .71-.71z" />
                </svg>
               
              </div>
              Google Play
            </motion.button>
          </div>
        </motion.div>
      </div>
    </section>
  );
};

export default MobileAppShowcase; 