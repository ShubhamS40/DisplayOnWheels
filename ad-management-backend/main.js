const express = require("express");
const dotenv = require("dotenv");
const { OpenAI } = require("openai");
const cors = require("cors");

dotenv.config();

const app = express();
const port = 5000;

// Middleware to parse JSON body
app.use(express.json());
app.use(cors({
  origin: "*",
  }))

const client = new OpenAI({
  apiKey: process.env.GROQ_API_KEY || "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",
  baseURL: "https://api.groq.com/openai/v1",
});

// POST API: Accept query in body
app.post("/ask", async (req, res) => {
  const userMessage = req.body.message;

  if (!userMessage) {
    return res.status(400).json({ error: "Missing 'message' in request body." });
  }

  try {
    const chatCompletion = await client.chat.completions.create({
      model: "llama3-8b-8192",
      messages: [
        { role: "system", content: "You are a helpful assistant." },
        { role: "user", content: userMessage }
      ],
      temperature: 0.7,
    });

    res.json({
      message: chatCompletion.choices[0].message.content,
    });
  } catch (error) {
    console.error("Groq API Error:", error);
    res.status(500).json({ error: "Failed to get response from Groq." });
  }
});

// Basic GET route
app.get("/", (req, res) => {
  res.json({ hello: "shubham" });
});

app.listen(port,'0.0.0.0', () => {
  console.log("Server running at http://localhost:${port}");
});
