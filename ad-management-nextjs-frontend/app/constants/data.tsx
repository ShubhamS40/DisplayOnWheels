'use client';

import React from 'react';
import { FaChartLine, FaUsers, FaBullseye, FaCog, FaShieldAlt, FaChartBar, FaMobileAlt, FaGlobe } from 'react-icons/fa';
import { FaTwitter, FaFacebook, FaLinkedin, FaInstagram } from 'react-icons/fa';
import type { Feature, Benefit, Testimonial, PricingPlan, NavItem, SocialLink } from '../types';

export const features: Feature[] = [
  {
    title: 'Real-time Analytics',
    description: 'Track your ad performance in real-time with detailed insights and metrics.',
    icon: <FaChartLine className="w-6 h-6" />,
  },
  {
    title: 'Audience Targeting',
    description: 'Reach your target audience with precision using advanced targeting options.',
    icon: <FaUsers className="w-6 h-6" />,
  },
  {
    title: 'Campaign Optimization',
    description: 'Automatically optimize your campaigns for better performance.',
    icon: <FaBullseye className="w-6 h-6" />,
  },
  {
    title: 'Easy Integration',
    description: 'Seamlessly integrate with your existing tools and platforms.',
    icon: <FaCog className="w-6 h-6" />,
  },
];

export const benefits: Benefit[] = [
  {
    title: 'Increased ROI',
    description: 'Maximize your return on investment with data-driven decisions.',
    icon: <FaChartBar className="w-6 h-6" />,
  },
  {
    title: 'Time Savings',
    description: 'Automate repetitive tasks and focus on strategic decisions.',
    icon: <FaMobileAlt className="w-6 h-6" />,
  },
  {
    title: 'Better Targeting',
    description: 'Reach the right audience at the right time with precision.',
    icon: <FaGlobe className="w-6 h-6" />,
  },
  {
    title: 'Secure Platform',
    description: 'Your data is protected with enterprise-grade security.',
    icon: <FaShieldAlt className="w-6 h-6" />,
  },
];

export const testimonials: Testimonial[] = [
  {
    name: 'Sarah Johnson',
    role: 'Marketing Director',
    content: 'Litvertise has transformed how we manage our advertising campaigns. The insights and automation features have saved us countless hours.',
    image: '/testimonials/sarah.jpg',
  },
  {
    name: 'Michael Chen',
    role: 'Digital Marketing Manager',
    content: 'The platform\'s ease of use and powerful features make it a game-changer for our marketing team. Highly recommended!',
    image: '/testimonials/michael.jpg',
  },
  {
    name: 'Emily Rodriguez',
    role: 'CEO',
    content: 'We\'ve seen a 40% increase in our ad performance since switching to Litvertise. The ROI has been incredible.',
    image: '/testimonials/emily.jpg',
  },
];

export const pricingPlans: PricingPlan[] = [
  {
    name: 'Starter',
    price: '$49',
    description: 'Perfect for small businesses',
    features: [
      'Up to 5 campaigns',
      'Basic analytics',
      'Email support',
      'Standard targeting',
    ],
    cta: 'Get Started',
  },
  {
    name: 'Professional',
    price: '$99',
    description: 'Ideal for growing businesses',
    features: [
      'Up to 20 campaigns',
      'Advanced analytics',
      'Priority support',
      'Advanced targeting',
      'API access',
    ],
    cta: 'Get Started',
    popular: true,
  },
  {
    name: 'Enterprise',
    price: 'Custom',
    description: 'For large organizations',
    features: [
      'Unlimited campaigns',
      'Custom analytics',
      '24/7 support',
      'Custom targeting',
      'API access',
      'Dedicated account manager',
    ],
    cta: 'Contact Sales',
  },
];

export const navItems: NavItem[] = [
  { label: 'Features', href: '#features' },
  { label: 'How It Works', href: '#how-it-works' },
  { label: 'Benefits', href: '#benefits' },
  { label: 'Pricing', href: '#pricing' },
  { label: 'Contact', href: '#contact' },
];

export const socialLinks: SocialLink[] = [
  {
    name: 'Twitter',
    href: '#',
    icon: <FaTwitter className="w-5 h-5" />,
  },
  {
    name: 'Facebook',
    href: '#',
    icon: <FaFacebook className="w-5 h-5" />,
  },
  {
    name: 'LinkedIn',
    href: '#',
    icon: <FaLinkedin className="w-5 h-5" />,
  },
  {
    name: 'Instagram',
    href: '#',
    icon: <FaInstagram className="w-5 h-5" />,
  },
]; 