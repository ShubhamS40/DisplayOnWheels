'use client';

import { motion } from 'framer-motion';
import { FaQuoteLeft } from 'react-icons/fa';

const testimonials = [
  {
    name: 'Sarah Johnson',
    role: 'Marketing Director',
    content: 'DisplayOnWheels has transformed how we manage our advertising campaigns. The insights and automation features have saved us countless hours.',
    bgColor: '#F8A717',
  },
  {
    name: 'Michael Chen',
    role: 'Digital Marketing Manager',
    content: 'The platform\'s ease of use and powerful features make it a game-changer for our marketing team. Highly recommended!',
    bgColor: '#FF914D',
  },
  {
    name: 'Emily Rodriguez',
    role: 'CEO',
    content: 'We\'ve seen a 40% increase in our ad performance since switching to DisplayOnWheels. The ROI has been incredible.',
    bgColor: '#F8A717',
  },
];

const Testimonials = () => {
  return (
    <section id="testimonials" className="section bg-[#F5F5F5] py-20">
      <div className="container">
        <motion.div
          className="text-center mb-16"
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.7 }}
        >
          <span className="inline-block px-4 py-1 mb-4 bg-[#F8A717]/10 text-[#F8A717] rounded-full text-sm font-medium">
            Client Success
          </span>
          <h2 className="text-3xl md:text-4xl font-bold mb-4 text-[#1E1E1E]">
            What Our Clients Say
          </h2>
          <p className="text-[#1E1E1E]/70 max-w-2xl mx-auto text-lg">
            Don't just take our word for it. Here's what businesses and drivers have to say about their
            experience with DisplayOnWheels.
          </p>
        </motion.div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {testimonials.map((testimonial, index) => (
            <motion.div
              key={testimonial.name}
              className="bg-white rounded-lg shadow-lg p-8 relative"
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: index * 0.2 }}
              whileHover={{ 
                y: -5, 
                boxShadow: "0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04)" 
              }}
            >
              <FaQuoteLeft className="text-[#F8A717] w-10 h-10 mb-6 opacity-20 absolute top-6 right-6" />
              <p className="text-[#1E1E1E]/70 mb-8 relative z-10 text-lg italic">"{testimonial.content}"</p>
              <div className="flex items-center">
                <div 
                  className="w-12 h-12 rounded-full flex items-center justify-center mr-4 text-white text-xl font-bold"
                  style={{ backgroundColor: testimonial.bgColor }}
                >
                  {testimonial.name.charAt(0)}
                </div>
                <div>
                  <h4 className="font-bold text-[#1E1E1E]">{testimonial.name}</h4>
                  <p className="text-sm text-[#1E1E1E]/70">{testimonial.role}</p>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default Testimonials; 