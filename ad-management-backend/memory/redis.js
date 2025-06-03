const { createClient } = require('redis');

const client = createClient({
    username: 'default',
    password: 'nwuVz7NHgbVxkq62Ing5ePkL0x8PbPQe',
    socket: {
        host: 'redis-14705.c264.ap-south-1-1.ec2.redns.redis-cloud.com',
        port: 14705
    }
});

client.on('error', (err) => console.log('Redis Client Error', err));

// Connect to Redis when this module is imported
client.connect().catch(err => console.error('Failed to connect to Redis:', err));

module.exports = client;
