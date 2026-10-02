# Scanner3D: Native iOS 3D Object Scanner

A native iOS 3D scanner built in **Swift**, **SwiftUI**, and **RealityKit** using Apple's `ObjectCaptureSession` and on-device photogrammetry reconstruction.

---

## 🛠 Features

- **Guided Object Capture**: Interactive camera viewfinder with AR bounding boxes and capture coverage indicators.
- **On-Device 3D Mesh Reconstruction**: Converts photos and LiDAR point clouds directly into high-fidelity `.usdz` 3D models right on your iPhone.
- **Interactive QuickLook 3D Viewer**: Rotate, zoom, and inspect generated 3D models in AR or 3D object space.
- **Export & Sharing**: Native iOS ShareLink to export `.usdz` files directly to Files, AirDrop, Blender, or your PC.
- **Zero-Mac Development**: Built and packaged via **free GitHub Actions cloud macOS runners**.
- **100% Free**: No $99/year Apple Developer account required.

---

## 🚀 How to Build & Install from Windows (No Mac Required)

Because iOS apps require macOS and Xcode to compile, we use **GitHub Actions** (which provides free Apple Silicon macOS runners) to build the app and output an `.ipa` installation file. You can then sideload it directly onto your iPhone from Windows using your regular free Apple ID.

### Step 1: Upload to GitHub

1. Open PowerShell / Terminal in this project directory:
   ```powershell
   cd C:\Users\Behnam\.gemini\antigravity\scratch\ios-3d-scanner
   ```
2. Initialize git and commit:
   ```powershell
   git init
   git add .
   git commit -m "Initial 3D Scanner iOS App"
   ```
3. Go to [GitHub](https://github.com) and create a **new repository** (e.g., `ios-3d-scanner`). Set it to **Public** (Public repositories get **unlimited free GitHub Actions**).
4. Link and push:
   ```powershell
   git branch -M main
   git remote add origin https://github.com/<YOUR_GITHUB_USERNAME>/ios-3d-scanner.git
   git push -u origin main
   ```

---

### Step 2: Download the Compiled IPA

1. Go to your repository on GitHub.
2. Click on the **Actions** tab at the top.
3. You will see the **Build iOS IPA** workflow running automatically.
4. Wait ~3–5 minutes for it to complete with a green checkmark.
5. Click on the finished workflow run.
6. Scroll down to **Artifacts** and download `Scanner3D-IPA.zip`.
7. Extract the zip on your Windows PC to get `Scanner3D.ipa`.

---

### Step 3: Install on your iPhone using Windows (Free Sideloading)

You do **not** need a paid Apple Developer account ($99/yr). A standard personal Apple ID allows installing up to 3 apps for 7 days (renewable anytime).

1. Download and install **iTunes** (standard Windows installer, not Microsoft Store version) and **iCloud** for Windows so your PC recognizes your iPhone.
2. Download **[Sideloadly](https://sideloadly.io/)** (Free tool for Windows).
3. Connect your iPhone to your Windows PC with a USB cable.
   - Unlock your iPhone and tap **"Trust This Computer"** if prompted.
4. Launch **Sideloadly**:
   - Your connected iPhone will show up under "iDevice".
   - Drag and drop `Scanner3D.ipa` into the Sideloadly window.
   - Enter your **Apple ID** email address.
   - Click **Start**.
   - (If prompted, enter your Apple ID password and 2-Factor Authentication code. Sideloadly communicates directly with Apple's developer servers to generate a free 7-day personal certificate).
5. Once it finishes, the **Scanner3D** app icon will appear on your iPhone home screen!

---

### Step 4: Allow the App on your iPhone

Before opening the app for the first time on iOS:
1. Open **Settings** on your iPhone.
2. Go to **General** > **VPN & Device Management**.
3. Under **Developer App**, tap your Apple ID and tap **"Trust"**.
4. Go to **Settings** > **Privacy & Security**.
5. Scroll down to **Developer Mode** and turn it **ON** (your phone will prompt you to reboot).
6. Launch **Scanner3D** and start scanning!
