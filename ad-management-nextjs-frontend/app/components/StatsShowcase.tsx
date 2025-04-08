'use client';

import { motion, useInView } from 'framer-motion';
import { useEffect, useRef, useState } from 'react';

interface Stat {
  value: number;
  suffix?: string;
  label: string;
  color: string;
}

const statsData: Stat[] = [
  { value: 5000, suffix: '+', label: 'Active Drivers', color: '#F8A717' },
  { value: 12000000, suffix: '+', label: 'Monthly Impressions', color: '#1E1E1E' },
  { value: 350, suffix: '+', label: 'Partner Brands', color: '#FF914D' },
  { value: 15, suffix: '', label: 'Cities Covered', color: '#F8A717' }
];

interface AnimatedCounterProps {
  target: number;
  suffix?: string;
  duration?: number;
}

const AnimatedCounter: React.FC<AnimatedCounterProps> = ({ target, suffix = '', duration = 2000 }) => {
  const [count, setCount] = useState(0);
  const ref = useRef<HTMLSpanElement | null>(null);
  const isInView = useInView(ref, { once: true, amount: 0.5 });

  useEffect(() => {
    if (!isInView) return;
    let startTime: number;
    let animationFrame: number;

    const updateCount = (timestamp: number) => {
      if (!startTime) startTime = timestamp;
      const progress = timestamp - startTime;
      const percentage = Math.min(progress / duration, 1);
      
      const easeOutQuad = (t: number) => t * (2 - t);
      const easedProgress = easeOutQuad(percentage);
      
      setCount(Math.floor(target * easedProgress));
      
      if (progress < duration) {
        animationFrame = requestAnimationFrame(updateCount);
      }
    };

    animationFrame = requestAnimationFrame(updateCount);
    return () => cancelAnimationFrame(animationFrame);
  }, [target, duration, isInView]);

  return (
    <span ref={ref} className="font-bold">
      {count.toLocaleString()}{suffix}
    </span>
  );
};

const StatsShowcase: React.FC = () => {
  return (
    <section className="bg-[#F5F5F5] py-20">
      <div className="container mx-auto px-6">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
          {statsData.map((stat, index) => (
            <motion.div
              key={index}
              className="bg-white rounded-lg shadow-lg p-6 text-center"
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: index * 0.1 }}
            >
              <div className="flex items-center justify-center mb-3">
                <div className="h-1 w-12 rounded-full" style={{ backgroundColor: stat.color }}></div>
              </div>
              <div className="text-3xl md:text-4xl font-bold mb-2" style={{ color: stat.color }}>
                <AnimatedCounter target={stat.value} suffix={stat.suffix} />
              </div>
              <div className="text-[#1E1E1E]/70">{stat.label}</div>
            </motion.div>
          ))}
        </div>
        
        <motion.div
          className="mt-16 text-center"
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
        >
          <p className="text-lg text-[#1E1E1E]/70 max-w-2xl mx-auto">
            Join the thousands of drivers and businesses who are already using DisplayOnWheels 
            to transform vehicle advertising.
          </p>
          <motion.button
            className="mt-6 bg-[#F8A717] text-white px-8 py-3 rounded-lg shadow-lg font-medium inline-flex items-center"
            whileHover={{ scale: 1.05, boxShadow: "0 10px 15px -3px rgba(248, 167, 23, 0.3)" }}
            whileTap={{ scale: 0.95 }}
          >
            Get Started Today
            <svg 
              xmlns="http://www.w3.org/2000/svg" 
              className="h-5 w-5 ml-2" 
              viewBox="0 0 20 20" 
              fill="currentColor"
            >
              <path 
                fillRule="evenodd" 
                d="M10.293 5.293a1 1 0 011.414 0l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414-1.414L12.586 11H5a1 1 0 110-2h7.586l-2.293-2.293a1 1 0 010-1.414z" 
                clipRule="evenodd" 
              />
            </svg>
          </motion.button>
        </motion.div>
      </div>
    </section>
  );
};

export default StatsShowcase;