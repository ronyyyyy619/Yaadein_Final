Yaadein 
Yaadein is a platform for families to preserve, organize, and share precious memories. It includes an AI-driven backend for analyzing and tagging photos, facial recognition, and interactive memory games. The platform also features a mobile app for iOS and Android, built with React, TypeScript, and Capacitor.

🎯 Project Overview
Yaadein is a robust memory management system powered by advanced AI models. The platform allows families to upload photos, videos, and audio recordings, collaborate on organizing and tagging memories, and engage in memory games. The backend handles intelligent photo tagging, facial recognition, and dynamic game sessions, while the frontend (web and mobile) provides a seamless user experience.

🏗️ Technology Stack
Backend (Yaadein AI Backend)
Runtime: Node.js 18+ with Express.js

Language: TypeScript for type safety and better development experience

AI Models: Hugging Face Inference API + OpenAI Vision API fallback

Primary: Salesforce/blip-image-captioning-large for image captioning

Secondary: microsoft/DialoGPT-medium for conversational tag suggestions

Facial Recognition: microsoft/DialoGPT-medium for face detection

Tag Generation: mistralai/Mistral-7B-Instruct-v0.1 for intelligent tagging

Database: Supabase PostgreSQL with Row Level Security (RLS)

File Storage: Supabase Storage with CDN optimization

Image Processing: Sharp.js for optimization

Caching: Redis for high-performance caching

Queue Management: Bull Queue for background processing

Security: Helmet.js, rate limiting, input validation with Express Validator

Monitoring: Winston logging

Frontend (Web and Mobile)
Frontend: React 18 + TypeScript + Tailwind CSS

Mobile: Capacitor for native iOS/Android apps

Icons: Lucide React

Routing: React Router

Build Tool: Vite

Backend: Supabase (Auth, Database, Storage)

🚀 Getting Started
Prerequisites
Backend:

Node.js 18+

Redis server

Supabase account and project

Hugging Face API key (for AI features)

OpenAI API key (optional, for fallback)

Frontend:

Node.js 18+ and npm

Android Studio (for Android development)

Xcode (for iOS development, macOS only)

Backend Installation
Clone the backend repository:

bash
Copy
Edit
git clone https://github.com/yourusername/yaadein-ai-backend.git
cd yaadein-ai-backend
Install dependencies:

bash
Copy
Edit
npm install
Create a .env file based on .env.example:

bash
Copy
Edit
cp .env.example .env
Update the .env file with your credentials and configuration.

Start the development server:

bash
Copy
Edit
npm run dev
Start the worker processes (in a separate terminal):

bash
Copy
Edit
npm run queue:worker
Frontend (Web & Mobile) Installation
Clone the repository:

bash
Copy
Edit
git clone https://github.com/yourusername/yaadein.git
cd yaadein
Install dependencies:

bash
Copy
Edit
npm install
Set up environment variables:

bash
Copy
Edit
cp .env.example .env
# Edit .env with your Supabase credentials
Start development server:

bash
Copy
Edit
npm run dev
Mobile App Development
Android Setup
Add Android platform:

bash
Copy
Edit
npm run cap:add:android
Build and sync:

bash
Copy
Edit
npm run android:build
Open in Android Studio:

bash
Copy
Edit
npm run android:open
Run on device/emulator:

bash
Copy
Edit
npm run android:dev
iOS Setup
Add iOS platform:

bash
Copy
Edit
npm run cap:add:ios
Build and sync:

bash
Copy
Edit
npm run ios:build
Open in Xcode:

bash
Copy
Edit
npm run ios:open
🗄️ Database Schema
The backend uses Supabase PostgreSQL with the following core tables:

users: User profiles and preferences

memories: Uploaded images and metadata

tags: AI-generated and user-created tags

people: Recognized individuals in photos

face_detections: Detected faces in images

game_sessions: Memory game sessions

collections: Memory collections/albums

🚀 API Endpoints
Memory Management
POST /api/v1/memories/analyze: Upload and analyze images

GET /api/v1/memories: Get user's memories

GET /api/v1/memories/:id: Get a specific memory

DELETE /api/v1/memories/:id: Delete a memory

GET /api/v1/memories/search: Search memories

People & Face Management
POST /api/v1/people: Create a new person

GET /api/v1/people: Get all people

GET /api/v1/people/:id: Get a specific person

PUT /api/v1/people/:id: Update a person

DELETE /api/v1/people/:id: Delete a person

GET /api/v1/people/:id/memories: Get memories containing a person

POST /api/v1/memories/:memory_id/faces/verify: Verify a face detection

Collections
POST /api/v1/collections: Create a collection

GET /api/v1/collections: Get all collections

GET /api/v1/collections/:id: Get a specific collection

PUT /api/v1/collections/:id: Update a collection

DELETE /api/v1/collections/:id: Delete a collection

POST /api/v1/collections/:id/memories: Add a memory to a collection

DELETE /api/v1/collections/:id/memories/:memory_id: Remove a memory from a collection

POST /api/v1/collections/auto-generate: Generate a smart collection

Games
POST /api/v1/games/start: Start a new game session

POST /api/v1/games/:session_id/answer: Submit an answer

GET /api/v1/games/history: Get game history

GET /api/v1/games/achievements: Get achievements

🔒 Security
JWT authentication

Rate limiting

Input validation

Helmet.js for security headers

Supabase Row Level Security (RLS)

🧪 Testing
bash
Copy
Edit
# Run tests
npm test

# Run tests with coverage
npm run test:coverage
🚀 Deployment
bash
Copy
Edit
# Build for production
npm run build

# Start production server
npm start
