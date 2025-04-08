'use client';

import { motion } from 'framer-motion';
import { FaCheck, FaCrown } from 'react-icons/fa';

const plans = [
  {
    name: 'Starter',
    price: 49,
    description: 'Perfect for small businesses getting started with car advertising.',
    features: [
      'Up to 5 active campaigns',
      'Basic analytics',
      'Standard support',
      'Email notifications',
      'Basic route optimization',
    ],
    cta: 'Get Started',
    popular: false,
  },
  {
    name: 'Professional',
    price: 99,
    description: 'Ideal for growing businesses looking to scale their advertising reach.',
    features: [
      'Up to 20 active campaigns',
      'Advanced analytics',
      'Priority support',
      'SMS notifications',
      'Advanced route optimization',
      'Custom reporting',
      'API access',
    ],
    cta: 'Start Free Trial',
    popular: true,
  },
  {
    name: 'Enterprise',
    price: 199,
    description: 'For large organizations requiring full-scale advertising solutions.',
    features: [
      'Unlimited campaigns',
      'Real-time analytics',
      '24/7 dedicated support',
      'Multi-channel notifications',
      'AI-powered optimization',
      'Custom reporting',
      'API access',
      'Dedicated account manager',
      'Custom integrations',
    ],
    cta: 'Contact Sales',
    popular: false,
  },
];

const Pricing = () => {
  return (
    <section id="pricing" className="section bg-white">
      <div className="container">
        <motion.div
          className="text-center mb-16"
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
        >
          <h2 className="text-3xl md:text-4xl font-bold mb-4">Simple, Transparent Pricing</h2>
          <p className="text-[#1E1E1E]/80 max-w-2xl mx-auto">
            Choose the perfect plan for your advertising needs. All plans include our core features.
          </p>
        </motion.div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {plans.map((plan, index) => (
            <motion.div
              key={plan.name}
              className={`bg-[#F5F5F5] rounded-lg shadow-lg p-6 relative ${
                plan.popular ? 'border-2 border-[#F8A717]' : ''
              }`}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: index * 0.2 }}
            >
              {plan.popular && (
                <div className="absolute -top-4 left-1/2 transform -translate-x-1/2">
                  <div className="bg-[#F8A717] text-white px-4 py-1 rounded-full text-sm font-medium flex items-center">
                    <FaCrown className="mr-2" />
                    Most Popular
                  </div>
                </div>
              )}
              <div className="text-center">
                <h3 className="text-2xl font-bold mb-2">{plan.name}</h3>
                <div className="mb-4">
                  <span className="text-4xl font-bold">${plan.price}</span>
                  <span className="text-[#1E1E1E]/70">/month</span>
                </div>
                <p className="text-[#1E1E1E]/80 mb-6">{plan.description}</p>
                <a
                  href="#get-started"
                  className={`rounded-lg px-4 py-2 shadow-lg text-white ${
                    plan.popular ? 'bg-[#F8A717] hover:bg-[#F8A717]/90' : 'bg-[#1E1E1E] hover:bg-[#1E1E1E]/90'
                  }`}
                >
                  {plan.cta}
                </a>
              </div>
              <ul className="mt-8 space-y-4">
                {plan.features.map((feature, i) => (
                  <li key={i} className="flex items-center text-[#1E1E1E]/80">
                    <FaCheck className="w-5 h-5 text-[#F8A717] mr-3" />
                    {feature}
                  </li>
                ))}
              </ul>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default Pricing; 