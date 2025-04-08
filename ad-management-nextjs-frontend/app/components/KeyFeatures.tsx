'use client';

import { motion } from 'framer-motion';
import { FaChartLine, FaShieldAlt, FaMoneyBillWave, FaRoute, FaUsers, FaBell } from 'react-icons/fa';
import Image from 'next/image';

const features = [
  {
    title: 'Real-Time Ad Tracking',
    icon: FaChartLine,
    color: '#F8A717',
    description: 'Monitor your advertisement performance in real-time with detailed analytics and insights.',
    benefits: [
      'Live view of ad impressions',
      'Geographic tracking',
      'Audience engagement metrics',
      'Performance analytics',
    ],
  },
  {
    title: 'Tamper Detection',
    icon: FaShieldAlt,
    color: '#FF914D',
    description: 'Advanced security features to ensure your advertisements remain intact and properly displayed.',
    benefits: [
      'Motion sensors',
      'GPS tracking',
      'Alert notifications',
      'Security monitoring',
    ],
  },
  {
    title: 'Earnings Management',
    icon: FaMoneyBillWave,
    color: '#F8A717',
    description: 'Streamlined payment system for drivers to track and manage their earnings efficiently.',
    benefits: [
      'Automated payments',
      'Earnings dashboard',
      'Payment history',
      'Tax documentation',
    ],
  },
  {
    title: 'Route Optimization',
    icon: FaRoute,
    color: '#FF914D',
    description: 'Smart route planning to maximize advertisement visibility and reach target audiences.',
    benefits: [
      'AI-powered routing',
      'Traffic analysis',
      'Area coverage tracking',
      'Schedule optimization',
    ],
  },
  {
    title: 'Audience Analytics',
    icon: FaUsers,
    color: '#F8A717',
    description: 'Comprehensive audience insights to help companies target their ideal customers.',
    benefits: [
      'Demographic data',
      'Behavioral analysis',
      'Engagement metrics',
      'Market insights',
    ],
  },
  {
    title: 'Smart Notifications',
    icon: FaBell,
    color: '#FF914D',
    description: 'Stay informed with intelligent notifications for important updates and opportunities.',
    benefits: [
      'Custom alerts',
      'Performance updates',
      'Maintenance reminders',
      'Opportunity notifications',
    ],
  },
];

const KeyFeatures = () => {
  return (
    <section id="features" className="section bg-white py-20">
      <div className="container">
        <motion.div
          className="text-center mb-16"
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.7 }}
        >
          <span className="inline-block px-4 py-1 mb-4 bg-[#F8A717]/10 text-[#F8A717] rounded-full text-sm font-medium">
            Why Choose Us
          </span>
          <h2 className="text-3xl md:text-4xl font-bold mb-4">Key Features</h2>
          <p className="text-[#1E1E1E]/70 max-w-2xl mx-auto text-lg">
            Discover the powerful features that make DisplayOnWheels the leading platform for car advertising.
          </p>
          
          {/* Center illustration */}
          <motion.div 
            className="mt-10 mb-16 flex justify-center"
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5, delay: 0.2 }}
          >
            <Image
              src="https://images.unsplash.com/photo-1525909002-1b05e0c869d8"
              alt="Car dashboard with analytics"
              width={600}
              height={350}
              className="rounded-lg shadow-lg object-cover"
            />
          </motion.div>
        </motion.div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {features.map((feature, index) => (
            <motion.div
              key={feature.title}
              className="bg-[#F5F5F5] rounded-lg shadow-lg p-6 hover:shadow-xl transition-all duration-300"
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: index * 0.1 }}
              whileHover={{ 
                y: -5,
                boxShadow: "0 20px 25px -5px rgba(0, 0, 0, 0.1)"
              }}
            >
              <div className="flex flex-col h-full">
                <div className="w-12 h-12 bg-white rounded-lg flex items-center justify-center mb-4 shadow-md">
                  <feature.icon className="w-6 h-6" style={{ color: feature.color }} />
                </div>
                <h3 className="text-xl font-bold mb-2 text-[#1E1E1E]">{feature.title}</h3>
                <p className="text-[#1E1E1E]/70 mb-4">{feature.description}</p>
                <ul className="space-y-2 mt-auto">
                  {feature.benefits.map((benefit, i) => (
                    <motion.li 
                      key={i} 
                      className="flex items-center text-[#1E1E1E]/70"
                      initial={{ opacity: 0, x: -10 }}
                      whileInView={{ opacity: 1, x: 0 }}
                      viewport={{ once: true }}
                      transition={{ duration: 0.3, delay: 0.3 + (i * 0.1) }}
                    >
                      <svg
                        className="w-4 h-4 mr-2 flex-shrink-0"
                        style={{ color: feature.color }}
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                        xmlns="http://www.w3.org/2000/svg"
                      >
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          strokeWidth={2}
                          d="M5 13l4 4L19 7"
                        />
                      </svg>
                      {benefit}
                    </motion.li>
                  ))}
                </ul>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default KeyFeatures; 