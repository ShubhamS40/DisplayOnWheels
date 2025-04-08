'use client';

import { motion } from 'framer-motion';
import { FaBuilding, FaCar, FaUserShield } from 'react-icons/fa';
import Image from 'next/image';

const steps = [
  {
    title: 'For Companies',
    icon: FaBuilding,
    description: 'Create and manage your advertising campaigns, track performance, and reach your target audience effectively.',
    steps: [
      'Create an account and set up your company profile',
      'Design and upload your advertisements',
      'Select target areas and demographics',
      'Track performance and analytics in real-time',
    ],
  },
  {
    title: 'For Drivers',
    icon: FaCar,
    description: 'Earn money by displaying advertisements on your vehicle while driving your regular routes.',
    steps: [
      'Sign up as a driver and verify your vehicle',
      'Choose advertisements that match your route',
      'Install the tracking device securely',
      'Start earning passive income',
    ],
  },
  {
    title: 'For Admins',
    icon: FaUserShield,
    description: 'Manage the platform, monitor compliance, and ensure smooth operations for all users.',
    steps: [
      'Monitor advertisement compliance',
      'Handle user verification and support',
      'Manage payment processing',
      'Generate platform analytics',
    ],
  },
];

const processSteps = [
  {
    number: '01',
    title: 'Sign Up',
    description: 'Create your account and verify your identity as a vehicle owner'
  },
  {
    number: '02',
    title: 'Install Display',
    description: 'We\'ll send you our proprietary display to install on your vehicle'
  },
  {
    number: '03',
    title: 'Start Earning',
    description: 'Drive normally and earn money as your vehicle displays ads around town'
  }
];

const HowItWorks = () => {
  return (
    <section className="py-20 bg-[#F5F5F5]">
      <div className="container mx-auto px-4">
        <motion.div
          className="text-center mb-16"
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.7 }}
        >
          <span className="inline-block px-4 py-1 mb-4 bg-[#F8A717]/10 text-[#F8A717] rounded-full text-sm font-medium">
            Getting Started
          </span>
          <h2 className="text-3xl md:text-4xl font-bold mb-4 text-[#1E1E1E]">
            How It Works
          </h2>
          <p className="text-[#1E1E1E]/70 max-w-2xl mx-auto text-lg">
            Join our network in three simple steps and start earning passive income with your vehicle
          </p>
        </motion.div>

        {/* Process Steps with connecting lines created with CSS */}
        <div className="relative max-w-4xl mx-auto">
          {/* Connecting line */}
          <div className="absolute left-1/2 top-0 bottom-0 w-1 bg-[#F8A717]/20 transform -translate-x-1/2 hidden md:block"></div>
          
          <div className="grid md:grid-cols-3 gap-8">
            {processSteps.map((step, index) => (
              <motion.div
                key={step.number}
                className="relative"
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.7, delay: index * 0.2 }}
              >
                <div className="bg-white rounded-xl p-6 shadow-lg relative z-10 h-full flex flex-col">
                  {/* Step number */}
                  <div className="w-12 h-12 bg-[#F8A717]/10 rounded-full flex items-center justify-center text-[#F8A717] font-bold text-xl mb-4">
                    {step.number}
                  </div>
                  
                  {/* Connection dot for the line (visible on md screens) */}
                  <div className="absolute top-1/2 left-0 w-4 h-4 bg-[#F8A717] rounded-full transform -translate-x-1/2 -translate-y-1/2 hidden md:block"></div>
                  
                  <h3 className="text-xl font-bold mb-2 text-[#1E1E1E]">{step.title}</h3>
                  <p className="text-[#1E1E1E]/70">{step.description}</p>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
        
        <motion.div
          className="text-center mt-12"
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.7, delay: 0.6 }}
        >
          <button className="bg-[#F8A717] text-white px-8 py-3 rounded-lg font-medium hover:bg-[#E5970F] transition">
            Get Started Today
          </button>
        </motion.div>
      </div>
    </section>
  );
};

export default HowItWorks; 