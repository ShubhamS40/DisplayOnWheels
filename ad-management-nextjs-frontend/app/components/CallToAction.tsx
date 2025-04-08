'use client';

import { motion, AnimatePresence } from 'framer-motion';
import { FaArrowRight, FaCar, FaBuilding, FaMapMarkerAlt, FaMoneyBillWave } from 'react-icons/fa';
import { useState } from 'react';

const CallToAction = () => {
  const [activeTab, setActiveTab] = useState('driver');
  const [adMessage, setAdMessage] = useState('My Business Ad');
  const [location, setLocation] = useState('Downtown');

  return (
    <section id="get-started" className="section bg-[#F5F5F5] overflow-hidden relative py-20">
      {/* Background Decorations */}
      <div className="absolute inset-0 overflow-hidden opacity-10 pointer-events-none">
        <div className="absolute top-0 right-0 w-1/2 h-1/2 bg-[#F8A717]/30 rounded-full blur-3xl transform translate-x-1/3 -translate-y-1/3"></div>
        <div className="absolute bottom-0 left-0 w-1/2 h-1/2 bg-[#FF914D]/20 rounded-full blur-3xl transform -translate-x-1/3 translate-y-1/3"></div>
      </div>
      
      <div className="container relative z-10">
        <div className="grid lg:grid-cols-2 gap-16 items-center">
          <motion.div
            initial={{ opacity: 0, x: -30 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.7 }}
          >
            <span className="inline-block px-4 py-1 mb-4 bg-[#F8A717]/10 text-[#F8A717] rounded-full text-sm font-medium">
              Join Our Network
            </span>
            <h2 className="text-3xl md:text-4xl font-bold mb-6 text-[#1E1E1E]">
              Start Your Journey with DisplayOnWheels Today!
            </h2>
            <p className="text-lg mb-8 text-[#1E1E1E]/70">
              Whether you're a driver looking to earn or a business aiming to reach mobile audiences, 
              our platform connects you for mutual success.
            </p>
            
            {/* Tabs for Different User Types */}
            <div className="flex bg-white rounded-lg p-1 shadow-md mb-8">
              <motion.button
                className={`flex-1 py-3 px-4 rounded-lg font-medium flex items-center justify-center ${
                  activeTab === 'driver' ? 'bg-[#F8A717] text-white' : 'text-[#1E1E1E]/70'
                }`}
                onClick={() => setActiveTab('driver')}
                whileHover={{ scale: activeTab !== 'driver' ? 1.02 : 1 }}
                whileTap={{ scale: 0.98 }}
              >
                <FaCar className="mr-2" />
                For Drivers
              </motion.button>
              <motion.button
                className={`flex-1 py-3 px-4 rounded-lg font-medium flex items-center justify-center ${
                  activeTab === 'business' ? 'bg-[#F8A717] text-white' : 'text-[#1E1E1E]/70'
                }`}
                onClick={() => setActiveTab('business')}
                whileHover={{ scale: activeTab !== 'business' ? 1.02 : 1 }}
                whileTap={{ scale: 0.98 }}
              >
                <FaBuilding className="mr-2" />
                For Businesses
              </motion.button>
            </div>
            
            {/* Dynamic Content Based on Tab */}
            <AnimatePresence mode="wait">
              <motion.div
                key={activeTab}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -20 }}
                transition={{ duration: 0.3 }}
              >
                {activeTab === 'driver' ? (
                  <div className="space-y-4">
                    <h3 className="text-xl font-bold text-[#1E1E1E]">Earn While You Drive</h3>
                    <p className="text-[#1E1E1E]/70">
                      Turn your daily commute into a revenue stream. Display ads on your vehicle and 
                      earn money with minimal effort.
                    </p>
                    <ul className="space-y-3">
                      {[
                        'Earn up to $500 extra per month',
                        'Flexible schedule - drive when you want',
                        'Easy installation process',
                        'Get paid weekly via direct deposit'
                      ].map((item, i) => (
                        <motion.li 
                          key={i}
                          className="flex items-start"
                          initial={{ opacity: 0, x: -10 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ delay: i * 0.1 }}
                        >
                          <div className="bg-[#F8A717]/10 rounded-full p-1 mr-3 mt-0.5">
                            <FaMoneyBillWave className="w-4 h-4 text-[#F8A717]" />
                          </div>
                          <span>{item}</span>
                        </motion.li>
                      ))}
                    </ul>
                    <motion.button
                      className="w-full bg-[#F8A717] hover:bg-[#F8A717]/90 text-white rounded-lg py-3 px-6 mt-6 font-medium shadow-lg flex items-center justify-center"
                      whileHover={{ scale: 1.02, boxShadow: "0 10px 15px -3px rgba(248, 167, 23, 0.3)" }}
                      whileTap={{ scale: 0.98 }}
                    >
                      Sign Up as a Driver
                      <FaArrowRight className="ml-2" />
                    </motion.button>
                  </div>
                ) : (
                  <div className="space-y-4">
                    <h3 className="text-xl font-bold text-[#1E1E1E]">Expand Your Reach</h3>
                    <p className="text-[#1E1E1E]/70">
                      Advertise your business on the go. Reach potential customers throughout the city with 
                      mobile ads that get noticed.
                    </p>
                    <ul className="space-y-3">
                      {[
                        'Target specific neighborhoods',
                        'Track impressions and engagement',
                        'Flexible campaign options',
                        'Cost-effective compared to traditional ads'
                      ].map((item, i) => (
                        <motion.li 
                          key={i}
                          className="flex items-start"
                          initial={{ opacity: 0, x: -10 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ delay: i * 0.1 }}
                        >
                          <div className="bg-[#FF914D]/10 rounded-full p-1 mr-3 mt-0.5">
                            <FaMapMarkerAlt className="w-4 h-4 text-[#FF914D]" />
                          </div>
                          <span>{item}</span>
                        </motion.li>
                      ))}
                    </ul>
                    <motion.button
                      className="w-full bg-[#FF914D] hover:bg-[#FF914D]/90 text-white rounded-lg py-3 px-6 mt-6 font-medium shadow-lg flex items-center justify-center"
                      whileHover={{ scale: 1.02, boxShadow: "0 10px 15px -3px rgba(255, 145, 77, 0.3)" }}
                      whileTap={{ scale: 0.98 }}
                    >
                      Register Your Business
                      <FaArrowRight className="ml-2" />
                    </motion.button>
                  </div>
                )}
              </motion.div>
            </AnimatePresence>
          </motion.div>
          
          {/* Interactive Demo */}
          <motion.div
            className="relative"
            initial={{ opacity: 0, x: 30 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.7 }}
          >
            <div className="bg-white rounded-lg shadow-lg p-6">
              <h3 className="text-xl font-bold mb-4 text-[#1E1E1E]">Try Our Ad Preview</h3>
              <p className="text-[#1E1E1E]/70 mb-6">
                Customize your ad and see how it would look on a vehicle in your target area.
              </p>
              
              <div className="space-y-4 mb-6">
                <div>
                  <label htmlFor="ad-text" className="block text-sm font-medium text-[#1E1E1E] mb-1">
                    Ad Message
                  </label>
                  <input
                    type="text"
                    id="ad-text"
                    value={adMessage}
                    onChange={(e) => setAdMessage(e.target.value)}
                    className="w-full px-4 py-2 bg-[#F5F5F5] rounded-lg border border-gray-200 focus:border-[#F8A717] focus:ring-2 focus:ring-[#F8A717]/30 transition-all"
                    placeholder="Enter your ad message"
                  />
                </div>
                
                <div>
                  <label htmlFor="location" className="block text-sm font-medium text-[#1E1E1E] mb-1">
                    Target Location
                  </label>
                  <select
                    id="location"
                    value={location}
                    onChange={(e) => setLocation(e.target.value)}
                    className="w-full px-4 py-2 bg-[#F5F5F5] rounded-lg border border-gray-200 focus:border-[#F8A717] focus:ring-2 focus:ring-[#F8A717]/30 transition-all"
                  >
                    <option value="Downtown">Downtown</option>
                    <option value="Suburbs">Suburbs</option>
                    <option value="Business District">Business District</option>
                    <option value="Shopping Mall">Shopping Mall</option>
                  </select>
                </div>
              </div>
              
              {/* Ad Preview */}
              <div className="relative bg-[#1E1E1E] rounded-lg p-4 h-48 mb-6 overflow-hidden">
                <div className="absolute inset-0 opacity-20">
                  {/* Map Background - Using a solid color for now */}
                  <div className="w-full h-full bg-[#1E1E1E] flex items-center justify-center">
                    <div className="text-white/50 text-lg">{location} Area</div>
                  </div>
                </div>
                
                {/* Car with Ad */}
                <motion.div
                  className="absolute bottom-4 left-1/2 transform -translate-x-1/2 bg-[#F8A717] px-6 py-3 rounded shadow-lg max-w-[80%]"
                  animate={{
                    x: ['-50%', '-45%', '-55%', '-50%'],
                  }}
                  transition={{
                    duration: 5,
                    repeat: Infinity,
                    ease: "easeInOut"
                  }}
                >
                  <div className="text-white font-bold text-center truncate">
                    {adMessage || "Your Ad Here"}
                  </div>
                </motion.div>
              </div>
              
              <div className="flex justify-center">
                <motion.button
                  className="bg-[#F8A717] hover:bg-[#F8A717]/90 text-white rounded-lg py-3 px-6 font-medium shadow-lg flex items-center justify-center"
                  whileHover={{ scale: 1.05, boxShadow: "0 10px 15px -3px rgba(248, 167, 23, 0.3)" }}
                  whileTap={{ scale: 0.95 }}
                >
                  Start a Real Campaign
                </motion.button>
              </div>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
};

export default CallToAction; 