'use client';

import { motion } from 'framer-motion';

const FAQ = () => {
  return (
    <section className="section bg-white py-20">
      <div className="container">
        <motion.div
          className="text-center mb-16"
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.7 }}
        >
          <span className="inline-block px-4 py-1 mb-4 bg-[#F8A717]/10 text-[#F8A717] rounded-full text-sm font-medium">
            Questions & Answers
          </span>
          <h2 className="text-3xl md:text-4xl font-bold mb-4 text-[#1E1E1E]">
            Frequently Asked Questions
          </h2>
          <p className="text-[#1E1E1E]/70 max-w-2xl mx-auto text-lg">
            Coming soon: Answers to your most common questions about DisplayOnWheels.
          </p>
        </motion.div>
      </div>
    </section>
  );
};

export default FAQ; 