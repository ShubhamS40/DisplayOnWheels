'use client';

import { motion } from 'framer-motion';
import { BiPhoneCall } from 'react-icons/bi';
import { FaPhone, FaEnvelope, FaMapMarkerAlt } from 'react-icons/fa';

const Contact = () => {
  return (
    <section id="contact" className="py-20 bg-white">
      <div className="container mx-auto px-6 md:px-12 lg:px-20">
        <motion.div
          className="text-center mb-12"
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.7 }}
        >
          <h2 className="text-3xl md:text-4xl font-bold text-[#1E1E1E]">
            Get in Touch
          </h2>
          <p className="text-[#1E1E1E]/70 max-w-2xl mx-auto text-lg mt-2">
            Have questions? We'd love to hear from you. Fill out the form below or reach us directly.
          </p>
        </motion.div>

        <div className="flex flex-col md:flex-row gap-10">
          {/* Contact Form */}
          <motion.div 
            className="bg-[#F5F5F5] p-8 rounded-lg shadow-lg w-full md:w-2/3"
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 0.7 }}
          >
            <form>
              <div className="mb-6">
                <label className="block text-[#1E1E1E] font-medium mb-2">Name</label>
                <input 
                  type="text" 
                  className="w-full p-3 rounded-lg border focus:outline-none focus:border-[#E89C08]"
                  placeholder="Enter your name" 
                />
              </div>
              <div className="mb-6">
                <label className="block text-[#1E1E1E] font-medium mb-2">Email</label>
                <input 
                  type="email" 
                  className="w-full p-3 rounded-lg border focus:outline-none focus:border-[#E89C08]"
                  placeholder="Enter your email" 
                />
              </div>
              <div className="mb-6">
                <label className="block text-[#1E1E1E] font-medium mb-2">Message</label>
                <textarea 
                  className="w-full p-3 rounded-lg border focus:outline-none focus:border-[#E89C08]"
                  rows={5} 
                  placeholder="Write your message here..."
                ></textarea>
              </div>
              <button 
                type="submit" 
                className="w-full bg-[#E89C08] text-white py-3 rounded-lg font-bold hover:bg-[#F8A717] transition-all"
              >
                Send Message
              </button>
            </form>
          </motion.div>

          {/* Contact Info */}
          <motion.div 
            className="w-full md:w-1/3 flex flex-col gap-6 text-[#1E1E1E]"
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 0.7 }}
          >
            <div className="flex items-center gap-4 p-4 bg-[#F5F5F5] rounded-lg shadow-lg">
              <BiPhoneCall className="text-[#E89C08] text-2xl" />
              <span className="text-lg font-medium">+91 234 567 890</span>
            </div>
            <div className="flex items-center gap-4 p-4 bg-[#F5F5F5] rounded-lg shadow-lg">
              <FaEnvelope className="text-[#E89C08] text-2xl" />
              <span className="text-lg font-medium">displayonwheels@gmail.com</span>
            </div>
            <div className="flex items-center gap-4 p-4 bg-[#F5F5F5] rounded-lg shadow-lg">
              <FaMapMarkerAlt className="text-[#E89C08] text-2xl" />
              <span className="text-lg font-medium">XYZ Street, Delhi, India</span>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
};

export default Contact;