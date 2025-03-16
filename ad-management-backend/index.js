// require("dotenv").config();
// const express = require("express");
// const { Together } = require("together-ai");

// const app = express();
// const port = 3000;

// // Middleware
// app.use(express.json());

// // Initialize Together AI
// const together = new Together({ apiKey: process.env.TOGETHER_AI_API_KEY });

// // Route to generate chat response
// app.post("/chat", async (req, res) => {
//     const { message } = req.body;

//     if (!message) {
//         return res.status(400).json({ error: "Message is required!" });
//     }

//     try {
//         const response = await together.chat.completions.create({
//             messages: [{ "role": "user", "content": message }],
//             model: "meta-llama/Meta-Llama-3.1-405B-Instruct-Turbo",
//         });

//         console.log(response.choices[0].message.content);
//         res.json({ response: response.choices[0].message.content });
//     } catch (error) {
//         console.error("Error:", error);
//         res.status(500).json({ error: "Something went wrong!" });
//     }
// });


// // Start the Express server
// app.listen(port, () => {
//     console.log(`Server running on http://localhost:${port}`);
// });

