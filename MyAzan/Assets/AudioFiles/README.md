# Audio Files Structure

This folder contains all audio files used by the MyAzan app.

## Folder Structure

```
Assets/AudioFiles/
├── Default/           # Default azan audio files (included in app bundle)
│   └── azan_notification.mp3
└── Custom/            # User-added custom audio files (stored in Documents)
    └── (user files will be stored here)
```

## File Types Supported

- **MP3** (.mp3) - Recommended format
- **WAV** (.wav) - High quality, larger file size
- **M4A** (.m4a) - Apple's preferred format
- **AIFF** (.aiff) - Uncompressed audio

## How It Works

### Default Audio Files
- Stored in `Assets/AudioFiles/Default/`
- Included in app bundle
- Available immediately after app installation
- Cannot be modified by users

### Custom Audio Files
- Stored in `Assets/AudioFiles/Custom/` (Documents directory)
- Added by users through the app
- Can be imported, renamed, and deleted
- Persist between app updates

## Adding Custom Audio Files

Users can add custom audio files through:
1. **Settings** → **Audio Management**
2. **Import** button to select files from device
3. **Rename** and **Delete** options for each file

## Technical Notes

- Default files are loaded from Bundle.main
- Custom files are loaded from Documents directory
- AudioFileManager handles both types seamlessly
- System sound fallback available if files are missing
