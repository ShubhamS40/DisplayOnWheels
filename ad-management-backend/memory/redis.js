const Redis = require('ioredis');
const redis = new Redis({
  host: '127.0.0.1', // or your Redis host
  port: 6379,        // default Redis port
  // password: '',   // if you use a password
});

module.exports = redis;

