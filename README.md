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

cp .env.example .env
# Edit .env with your Supabase credentials
Start development server:

npm run dev
Mobile App Development
Android Setup
Add Android platform:

npm run cap:add:android
Build and sync:

npm run android:build
Open in Android Studio:

npm run android:open
Run on device/emulator:

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
