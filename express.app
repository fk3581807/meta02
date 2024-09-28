// Import required modules
const express = require('express');
const TelegramBot = require('node-telegram-bot-api');

// Create an Express app instance
const app = express();

// Set up Telegram bot token
const TOKEN = 7828935928:AAEZagEM2dQoKGeeIfI6swcJlGWvQn8EqgI;

// Create a Telegram bot instance
const bot = new TelegramBot(TOKEN, { polling: true });

// Middleware to parse JSON bodies
app.use(express.json());

// Webhook endpoint
app.post('/webhook', (req, res) => {
  bot.processUpdate(req.body);
  res.sendStatus(200);
});

// Start Express server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

// Set Telegram bot webhook
bot.setWebhook(`https://${process.env.VERCEL_URL}/webhook`);

// Handle /start command
bot.onText(/\/start/, (msg) => {
  bot.sendMessage(msg.chat.id, 'Enter a Google Drive file link:');
});

// Handle incoming messages
bot.on('message', (msg) => {
  const link = msg.text;
  const fileId = extractFileId(link);
  if (fileId) {
    const downloadLink = `https://www.googleapis.com/drive/v3/files/${fileId}?alt=media&key=${process.env.GOOGLE_DRIVE_API_KEY}`;
    bot.sendMessage(msg.chat.id, `Direct Download Link: ${downloadLink}`, {
      caption: 'Direct Download Link',
    });
  } else {
    bot.sendMessage(msg.chat.id, 'Invalid Google Drive file link format.');
  }
});

// Function to extract file ID from Google Drive link
function extractFileId(link) {
  const regex = /\/file\/d\/([^\/]+)/;
  const match = link.match(regex);
  return match && match[1];
}

module.exports = app;

