PS Institute is a full-stack Learning Management System (LMS) designed for teachers and students, enabling seamless assignment management, homework submission, notes sharing, and doubt resolution — all in one platform.

Built with Flutter + Firebase, the app focuses on clean UI, role-based access, and real-world classroom workflows.

✨ Key Features
👩‍🏫 Teacher Features

Create & manage assignments and homework

Upload and manage notes

View student submissions

Answer student doubts

Manage teacher profile (subject, bio, photo)

👨‍🎓 Student Features

View assignments, homework, and notes

Submit homework and assignments

Ask doubts directly to teachers

Track academic content easily

🔐 Authentication & Roles

Firebase Authentication

Role-based access (Teacher / Student)

Secure Firestore rules

🛠 Tech Stack
Layer	Technology
Frontend	Flutter (Dart)
Backend	Firebase
Database	Cloud Firestore
Storage	Firebase Storage (for files & images)
State Mgmt	Provider
Auth	Firebase Authentication
📂 Project Structure
ps_institute/
│
├── lib/
│   ├── config/           # App routes, themes, constants
│   ├── core/             # Reusable widgets, utils, validators
│   ├── data/
│   │   ├── models/       # Data models (User, Assignment, Notes, etc.)
│   │   └── repositories/ # Firestore interaction logic
│   ├── presentation/
│   │   ├── screens/      # UI screens (Teacher & Student)
│   │   ├── components/   # UI components
│   │   └── viewmodels/   # State management
│   └── main.dart         # App entry point
│
├── android/
├── ios/
├── pubspec.yaml
└── README.md

🚀 Getting Started
1️⃣ Clone the Repository
git clone https://github.com/your-username/ps-institute.git
cd ps-institute

2️⃣ Install Dependencies
flutter pub get

3️⃣ Firebase Setup

Create a Firebase project

Enable:

Authentication (Email/Password)

Cloud Firestore

Firebase Storage

Add google-services.json (Android)

Add GoogleService-Info.plist (iOS)

4️⃣ Run the App
flutter run

🔐 Firestore Collections Used

users

assignments

homework

notes

submissions

doubts

Each document is structured with role-based ownership for security and scalability.

🎯 Project Goals

Build a real-world LMS used in schools & coaching institutes

Practice clean architecture in Flutter

Implement role-based access control

Gain hands-on experience with Firebase at scale

📌 Future Improvements

Admin dashboard

Push notifications

File preview inside app

Analytics for teachers

AI-based doubt answering (planned)

👤 Author

Aditya Jha
🎓 Student at IIT Madras 
💻 Aspiring Software Engineer / Data Scientist
