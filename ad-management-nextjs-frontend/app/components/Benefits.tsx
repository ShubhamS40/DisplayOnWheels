'use client';

import { motion, useAnimation } from 'framer-motion';
import { useEffect, useRef } from 'react';
import { FaChartBar, FaUsers, FaCar, FaHandshake } from 'react-icons/fa';

const benefits = [
  {
    title: 'For Companies',
    icon: FaChartBar,
    stats: [
      { label: 'Ad Reach', value: 1000000, suffix: '+' },
      { label: 'Cost per Mile', value: 0.05, suffix: '$' },
      { label: 'ROI Increase', value: 150, suffix: '%' },
    ],
    description: 'Maximize your advertising impact with targeted campaigns and real-time analytics.',
  },
  {
    title: 'For Drivers',
    icon: FaCar,
    stats: [
      { label: 'Average Earnings', value: 500, suffix: '$' },
      { label: 'Active Drivers', value: 5000, suffix: '+' },
      { label: 'Flexible Hours', value: 100, suffix: '%' },
    ],
    description: 'Turn your daily commute into a source of passive income with our platform.',
  },
  {
    title: 'For Admins',
    icon: FaHandshake,
    stats: [
      { label: 'Platform Growth', value: 200, suffix: '%' },
      { label: 'User Satisfaction', value: 98, suffix: '%' },
      { label: 'Support Response', value: 24, suffix: 'h' },
    ],
    description: 'Efficiently manage and scale the platform while ensuring user satisfaction.',
  },
];

const AnimatedCounter = ({ value, suffix }: { value: number; suffix: string }) => {
  const controls = useAnimation();
  const ref = useRef(null);

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          controls.start({ opacity: 1, y: 0 });
        }
      },
      { threshold: 0.5 }
    );

    if (ref.current) {
      observer.observe(ref.current);
    }

    return () => observer.disconnect();
  }, [controls]);

  return (
    <motion.div
      ref={ref}
      initial={{ opacity: 0, y: 20 }}
      animate={controls}
      transition={{ duration: 0.5 }}
      className="text-3xl font-bold text-[#F8A717]"
    >
      {value.toLocaleString()}{suffix}
    </motion.div>
  );
};

const Benefits = () => {
  return (
    <section id="benefits" className="section bg-white">
      <div className="container">
        <motion.div
          className="text-center mb-16"
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
        >
          <h2 className="text-3xl md:text-4xl font-bold mb-4">Benefits</h2>
          <p className="text-[#1E1E1E]/80 max-w-2xl mx-auto">
            Join thousands of satisfied users who are already experiencing the advantages of DisplayOnWheels.
          </p>
        </motion.div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {benefits.map((benefit, index) => (
            <motion.div
              key={benefit.title}
              className="bg-[#F5F5F5] rounded-lg shadow-lg p-6"
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: index * 0.2 }}
            >
              <div className="flex flex-col items-center text-center">
                <div className="w-16 h-16 bg-[#F8A717]/10 rounded-full flex items-center justify-center mb-4">
                  <benefit.icon className="w-8 h-8 text-[#F8A717]" />
                </div>
                <h3 className="text-xl font-bold mb-2">{benefit.title}</h3>
                <p className="text-[#1E1E1E]/80 mb-6">{benefit.description}</p>
                <div className="space-y-4 w-full">
                  {benefit.stats.map((stat, i) => (
                    <div key={i} className="text-center">
                      <div className="text-sm text-[#1E1E1E]/70 mb-1">{stat.label}</div>
                      <AnimatedCounter value={stat.value} suffix={stat.suffix} />
                    </div>
                  ))}
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default Benefits; 