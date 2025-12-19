rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // allow delete user files
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      allow delete: if request.auth.uid == userId;
    }
    
    // team term fires
    match /teams/{teamId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
      
      match /members/{memberId} {
        allow delete: if request.auth.uid == memberId;
      }
    }
    
    // others
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
