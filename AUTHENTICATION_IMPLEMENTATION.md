# BreatheSafe iOS Authentication Implementation

This document describes the authentication system implemented for the BreatheSafe iOS app to communicate with the Rails backend.

## Overview

The authentication system allows managers to:
- Login with email and password
- View their managed users
- Capture facial measurements on behalf of managed users
- Export measurements to the Rails backend
- Work offline with automatic sync when connected

## Architecture

### Core Components

1. **AuthenticationService** - Handles login/logout and session management
2. **APIClient** - Manages API communication with Rails backend
3. **OfflineSyncManager** - Handles offline data storage and synchronization
4. **LoginViewController** - Authentication UI
5. **FaceMeasurementViewController** - Updated to work with authentication

### Data Flow

```
User Login → AuthenticationService → Rails Backend
     ↓
Load Managed Users → Select User → Capture Measurements
     ↓
Export Measurements → APIClient → Rails Backend
     ↓
Offline Storage (if network fails) → Sync when connected
```

## Authentication Flow

### 1. Login Process
- User enters email and password
- `AuthenticationService` sends credentials to `/users/log_in`
- On success, credentials are stored securely in Keychain
- Managed users are loaded from `/managed_users`

### 2. User Selection
- Manager selects a managed user from the list
- App navigates to `FaceMeasurementViewController` with selected user
- Title shows the selected user's name

### 3. Measurement Export
- After capturing measurements, user can export data
- Primary option: "Send to BreatheSafe Server"
- Data is sent to `/users/:user_id/facial_measurements_from_arkit`
- If network fails, data is saved offline for later sync

### 4. Offline Support
- Failed exports are automatically saved locally
- When network is restored, pending measurements are synced
- Retry logic with exponential backoff (max 3 attempts)

## Security Features

### Credential Storage
- Email and password stored securely in iOS Keychain
- Automatic session restoration on app launch
- Credentials cleared on logout

### Authentication Headers
- Session tokens sent in Authorization headers
- Proper error handling for 401 Unauthorized responses

## API Endpoints Used

### Authentication
- `POST /users/log_in` - User login
- `DELETE /users/log_out` - User logout
- `GET /users/get_current_user` - Get current user info

### User Management
- `GET /managed_users` - Get managed users
- `POST /managed_users` - Create new managed user
- `DELETE /managed_users/:id` - Delete managed user

### Data Export
- `POST /users/:user_id/facial_measurements_from_arkit` - Export measurements

## Error Handling

### Authentication Errors
- Invalid credentials
- Network connectivity issues
- Server errors (4xx, 5xx)
- Session expiration

### Export Errors
- Unauthorized access (401)
- Validation errors (422)
- Network failures (offline storage)
- User not managed by current user

## Offline Capabilities

### Data Storage
- Failed exports saved to Documents/PendingMeasurements/
- JSON format with metadata (timestamp, retry count, user ID)
- Automatic cleanup after successful sync

### Sync Process
- Triggered on app launch and network restoration
- Processes pending measurements in chronological order
- Retry logic with exponential backoff
- Removes files after 3 failed attempts

## Usage Instructions

### For Managers
1. Launch app and login with email/password
2. Select a managed user from the list
3. Capture facial measurements using ARKit
4. Export data to BreatheSafe server
5. Logout when finished

### For Developers
1. Ensure Rails backend is running on `https://breathesafe.xyz`
2. Test with valid manager credentials
3. Verify managed users are properly loaded
4. Test offline functionality by disabling network

## Configuration

### Base URL
The app is configured to use `https://breathesafe.xyz` as the base URL. This can be changed in:
- `AuthenticationService.baseURL`
- `APIClient.baseURL`

### Timeouts
- Request timeout: 30 seconds
- Resource timeout: 60 seconds

## Testing

### Test Scenarios
1. **Happy Path**: Login → Select User → Capture → Export
2. **Network Failure**: Export fails → Offline storage → Sync on reconnect
3. **Invalid Credentials**: Login with wrong password
4. **Session Expiry**: Long idle time → Re-authentication required
5. **No Managed Users**: Manager with no managed users

### Error Cases
- Invalid email/password
- Network connectivity issues
- Server errors (500, 503)
- Unauthorized access to user data
- Validation errors from Rails backend

## Future Enhancements

### Potential Improvements
1. **Token-based Authentication**: Replace session cookies with JWT tokens
2. **Biometric Authentication**: Face ID/Touch ID for quick login
3. **Background Sync**: Sync pending data in background
4. **Push Notifications**: Notify when sync completes
5. **Data Encryption**: Encrypt offline stored measurements
6. **Analytics**: Track usage patterns and error rates

### API Key Authentication
As mentioned in the requirements, API key authentication can be implemented by:
1. Adding API key field to login form
2. Storing API key in Keychain
3. Sending API key in Authorization header
4. Updating Rails backend to accept API key authentication

## Troubleshooting

### Common Issues
1. **Login Fails**: Check network connectivity and credentials
2. **No Managed Users**: Verify manager has created managed users
3. **Export Fails**: Check user permissions and network
4. **Offline Sync Issues**: Clear pending measurements and retry

### Debug Information
- Check console logs for authentication events
- Verify Keychain storage for saved credentials
- Monitor network requests in debugger
- Check Documents directory for pending measurements