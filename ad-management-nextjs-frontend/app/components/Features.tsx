'use client';

import { motion, useInView } from 'framer-motion';
import { useRef, useState } from 'react';
import {
  FaRoute, FaChartLine, FaMoneyBillWave,
  FaMobileAlt, FaMapMarkedAlt, FaShieldAlt
} from 'react-icons/fa';

const features = [
  {
    title: 'Smart Tracking',
    description: 'Real-time GPS tracking and analytics for optimal ad placement and performance monitoring.',
    icon: FaRoute,
    color: '#F8A717'
  },
  {
    title: 'Live Analytics',
    description: 'Monitor impressions, engagement, and ROI with our powerful real-time dashboard.',
    icon: FaChartLine,
    color: '#FF914D'
  },
  {
    title: 'Secure Payments',
    description: 'Automated, secure payment processing for hassle-free earnings.',
    icon: FaMoneyBillWave,
    color: '#F8A717'
  },
  {
    title: 'Mobile Control',
    description: 'Manage your campaigns on the go with our intuitive mobile application.',
    icon: FaMobileAlt,
    color: '#FF914D'
  },
  {
    title: 'Area Targeting',
    description: 'Target specific neighborhoods and demographics with precision advertising.',
    icon: FaMapMarkedAlt,
    color: '#F8A717'
  },
  {
    title: 'Secure Platform',
    description: 'Advanced encryption and security features to protect your data and transactions.',
    icon: FaShieldAlt,
    color: '#FF914D'
  }
];

const Features = () => {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: false, amount: 0.2 });

  return (
    <section id="features" className="section py-20 bg-white relative overflow-hidden">
      <div className="container relative z-10">
        <motion.div
          className="text-center mb-16"
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.7 }}
        >
          <span className="inline-block px-4 py-1 mb-4 bg-[#F8A717]/10 text-[#F8A717] rounded-full text-sm font-medium">
            Powerful Capabilities
          </span>
          <h2 className="text-3xl md:text-4xl font-bold mb-4 text-[#1E1E1E]">
            Smart Features for Modern Advertising
          </h2>
          <p className="text-[#1E1E1E]/70 max-w-2xl mx-auto text-lg">
            Our platform combines cutting-edge technology with user-friendly design to revolutionize mobile advertising.
          </p>
        </motion.div>

        <div className="flex flex-col md:flex-row items-center gap-10">
          <div className="w-full md:w-1/2 h-auto">
            <img
              src="https://img.freepik.com/free-vector/realistic-front-view-smartphone-mockup-mobile-iphone-purple-frame-with-blank-white-display-vector_90220-959.jpg?t=st=1743011033~exp=1743014633~hmac=01aef9069ccaf5c7d399c8ace0896737d3f60909da6dce54ca937ce56e3fbd01&w=1380"
              alt="Smartphone Mockup"
              className="w-full h-full object-cover rounded-lg"
            />
          </div>

          <motion.div
            className="grid grid-cols-1 md:grid-cols-2 gap-6 w-full md:w-1/2"
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true }}
            ref={ref}
          >
            {features.map((feature, index) => (
              <motion.div
                key={index}
                className="bg-[#F5F5F5] rounded-lg p-6 hover:bg-[#E89C08] hover:text-white transition-all duration-300 cursor-pointer shadow-md"
                whileHover={{ scale: 1.05 }}
              >
                <div className="w-12 h-12 bg-white rounded-lg flex items-center justify-center mb-4 shadow-md">
                  <feature.icon className="w-6 h-6" style={{ color: feature.color }} />
                </div>
                <h3 className="text-xl font-bold mb-2">{feature.title}</h3>
                <p>{feature.description}</p>
              </motion.div>
            ))}
          </motion.div>
        </div>
      </div>
    </section>
  );
};

export default Features;