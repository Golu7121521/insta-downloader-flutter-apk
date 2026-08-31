# Video Preview App (Placeholder Backend)

Premium dark-themed Flutter app: paste a link, fetch, preview in a 9:16
rounded video player, save to gallery.

## Current state
- `lib/video_api_service.dart` calls a **placeholder** endpoint
  (`https://jsonplaceholder.typicode.com/todos/1`) and returns a mocked
  public sample MP4 (`https://www.w3schools.com/html/mov_bbb.mp4`) for
  preview purposes.

## To wire up your real backend
Edit `lib/video_api_service.dart`:
1. Replace `placeholderEndpoint` with your authenticated API URL.
2. In `fetchVideoUrl`, parse the real JSON response and return the actual
   `download_url` field instead of `mockDownloadUrl`.
3. Add any required auth headers to the `http.get(...)` call.

No other files need to change — `HomePage`, `VideoPreviewPlayer`, and the
gallery-save logic are already generic and will work with any resolved
MP4 URL.

## Run
```
flutter pub get
flutter run
```
