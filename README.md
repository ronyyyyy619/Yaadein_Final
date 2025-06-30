
# Yaadein 

Yaadein is a platform for families to preserve, organize, and share precious memories. It includes an AI-driven backend for analyzing and tagging photos, facial recognition, and interactive memory games. The platform also features a mobile app for iOS and Android, built with React, TypeScript, and Capacitor.

Yaadein 
A collaborative platform for families to preserve, organize, and share precious memories. Built with React, TypeScript, and Capacitor for native mobile app deployment.

Features
📸 Memory Capture: Upload photos, videos, and audio recordings
👨‍👩‍👧‍👦 Family Collaboration: Invite family members to contribute
🏷️ Smart Organization: AI-powered tagging and categorization
🎮 Memory Games: Cognitive wellness activities
🔍 Advanced Search: Find memories quickly
🔒 Privacy Controls: Secure family data
📱 Native Mobile App: Available for Android and iOS
Tech Stack
Frontend: React 18 + TypeScript + Tailwind CSS
Backend: Supabase (Auth, Database, Storage)
Mobile: Capacitor for native iOS/Android apps
Icons: Lucide React
Routing: React Router
Build Tool: Vite
Development Setup
Prerequisites
Node.js 18+ and npm
Android Studio (for Android development)
Xcode (for iOS development, macOS only)
Installation
Clone and install dependencies:


git clone <repository-url>
cd memorymesh
npm install
Set up environment variables:


Yaadein is a robust memory management system powered by advanced AI models. The platform allows families to upload photos, videos, and audio recordings, collaborate on organizing and tagging memories, and engage in memory games. The backend handles intelligent photo tagging, facial recognition, and dynamic game sessions, while the frontend (web and mobile) provides a seamless user experience.


cp .env.example .env
# Edit .env with your Supabase credentials
Start development server:


npm run dev
Mobile App Development
Android Setup
Add Android platform:


### Backend (Yaadein AI Backend)

- **Runtime**: Node.js 18+ with Express.js
- **Language**: TypeScript for type safety and better development experience
- **AI Models**: Hugging Face Inference API + OpenAI Vision API fallback
  - **Primary**: `Salesforce/blip-image-captioning-large` for image captioning
  - **Secondary**: `microsoft/DialoGPT-medium` for conversational tag suggestions
  - **Facial Recognition**: `microsoft/DialoGPT-medium` for face detection
  - **Tag Generation**: `mistralai/Mistral-7B-Instruct-v0.1` for intelligent tagging
- **Database**: Supabase PostgreSQL with Row Level Security (RLS)
- **File Storage**: Supabase Storage with CDN optimization
- **Image Processing**: Sharp.js for optimization
- **Caching**: Redis for high-performance caching
- **Queue Management**: Bull Queue for background processing
- **Security**: Helmet.js, rate limiting, input validation with Express Validator
- **Monitoring**: Winston logging

### Frontend (Web and Mobile)

- **Frontend**: React 18 + TypeScript + Tailwind CSS
- **Mobile**: Capacitor for native iOS/Android apps
- **Icons**: Lucide React
- **Routing**: React Router
- **Build Tool**: Vite
- **Backend**: Supabase (Auth, Database, Storage)



## 🚀 Getting Started

npm run cap:add:android
Build and sync:

npm run android:build
Open in Android Studio:


npm run android:open
Run on device/emulator:


- **Backend**: 
  - Node.js 18+
  - Redis server
  - Supabase account and project
  - Hugging Face API key (for AI features)
  - OpenAI API key (optional, for fallback)
  
- **Frontend**: 
  - Node.js 18+ and npm
  - Android Studio (for Android development)
  - Xcode (for iOS development, macOS only)


### Backend Installation

1. Clone the backend repository:
   ```bash
   git clone https://github.com/yourusername/yaadein-ai-backend.git
   cd yaadein-ai-backend

npm run android:dev
iOS Setup
Add iOS platform:

npm run cap:add:ios
Build and sync:

npm run ios:build
Open in Xcode:

npm run ios:open
Building for Production
Web App
npm run build
Android APK/AAB
Open project in Android Studio: npm run android:open
Build → Generate Signed Bundle/APK
Follow the signing process for Play Store submission
iOS App
Open project in Xcode: npm run ios:open
Archive and upload to App Store Connect
Google Play Store Submission
Prepare for Release
Update version in package.json and capacitor.config.ts
Generate app icons and splash screens
Create signed APK/AAB in Android Studio
Test thoroughly on various devices
Play Store Requirements
App Icons: 512x512 PNG (high-res icon)
Screenshots: Phone and tablet screenshots
Feature Graphic: 1024x500 PNG
Privacy Policy: Required for apps handling personal data
App Description: Compelling store listing
Content Rating: Complete questionnaire
Target API Level: Android 13+ (API 33+)
Store Listing Assets
Create these assets for the Play Store:

Short Description (80 chars): "Preserve & share family memories together"
Full Description: Detailed feature list and benefits
Keywords: family, memories, photos, dementia, elderly, collaboration
Screenshots: Show key features and user interface
Feature Graphic: Branded promotional image
App Features for Store
Core Features
✅ Family memory timeline
✅ Photo/video/audio upload
✅ User authentication
✅ Responsive design
✅ Offline support
✅ Native camera integration
✅ Share functionality
✅ Haptic feedback
Planned Features
🔄 AI-powered memory organization
🔄 Memory recall games
🔄 Advanced search
🔄 Family member invitations
🔄 Push notifications
🔄 Cloud backup
Privacy & Security
End-to-end encryption for sensitive data
GDPR compliant data handling
Secure authentication with Supabase
Family-only access controls
Local data caching for offline use

